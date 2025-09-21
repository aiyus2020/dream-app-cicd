# --------------------------
# Get the latest Ubuntu 20.04 AMI
# --------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# --------------------------
# EC2 Instance (no provisioners here)
# --------------------------
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false   # We’ll attach Elastic IP manually
  key_name                    = "terraform-deploy"

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# --------------------------
# Lookup existing Elastic IP (this was missing before 🚀)
# --------------------------
data "aws_eip" "existing_eip" {
  public_ip = var.elastic_ip
}

# --------------------------
# Associate existing Elastic IP with EC2
# --------------------------
resource "aws_eip_association" "ec2_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = data.aws_eip.existing_eip.id
}

# --------------------------
# Provisioners (run after EIP association)
# --------------------------
resource "null_resource" "provisioners" {
  depends_on = [aws_eip_association.ec2_assoc]

  provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = data.aws_eip.existing_eip.public_ip
      timeout     = "10m"
    }
  }

 provisioner "remote-exec" {
  inline = [
    # Update system
    "sudo apt-get update -y",
    "sudo apt-get upgrade -y",

    # Install dependencies
    "sudo apt install -y jq ca-certificates curl gnupg lsb-release software-properties-common",

    # Install Docker
    "sudo mkdir -p /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt-get update -y",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
    "sudo systemctl enable docker",
    "sudo systemctl start docker",
    "sudo usermod -aG docker ubuntu",

    # Install Nginx
    "sudo apt-get install -y nginx",
    "sudo systemctl enable nginx",
    "sudo systemctl start nginx",
    "sudo ufw allow 'Nginx Full'",
    "sudo ufw delete allow 'Nginx HTTP'",

    # Install Certbot (before we touch configs!)
    "sudo apt-get install -y certbot python3-certbot-nginx",

    # Replace Nginx config
    "sudo mv /tmp/nginx.conf /etc/nginx/sites-available/default",
    "sudo nginx -t",

    # Run certbot (creates /etc/letsencrypt/options-ssl-nginx.conf)
    "sudo certbot --nginx -d aiyusdreamapp.name.ng -d www.aiyusdreamapp.name.ng --non-interactive --agree-tos -m admin@aiyusdreamapp.name.ng",

    # Reload Nginx AFTER certbot fixed the config
    "sudo systemctl reload nginx",

    # Check certbot status + test renewal
    "sudo systemctl status certbot.timer",
    "sudo certbot renew --dry-run",
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = data.aws_eip.existing_eip.public_ip
    timeout     = "10m"
  }
}

}

# --------------------------
# Route 53 Hosted Zone
# --------------------------
data "aws_route53_zone" "main" {
  name         = "aiyusdreamapp.name.ng"
  private_zone = false
}

# --------------------------
# Route 53 Records
# --------------------------
resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "aiyusdreamapp.name.ng"
  type    = "A"
  ttl     = 300
  records = [data.aws_eip.existing_eip.public_ip]
}

resource "aws_route53_record" "frontend_www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.aiyusdreamapp.name.ng"
  type    = "A"
  ttl     = 300
  records = [data.aws_eip.existing_eip.public_ip]
}
