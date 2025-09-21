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
# EC2 Instance
# --------------------------
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true   # ✅ Now we just use its own public IP
  key_name                    = var.key_name

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# --------------------------
# Provisioners
# --------------------------
resource "null_resource" "provisioners" {
  depends_on = [aws_instance.ec2]

  provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = aws_instance.ec2.public_ip
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",

      # Dependencies
      "sudo apt install -y jq ca-certificates curl gnupg lsb-release software-properties-common",

      # Docker
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",

      # Nginx + Certbot
      "sudo apt-get install -y nginx certbot python3-certbot-nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo ufw allow 'Nginx Full'",
      "sudo mv /tmp/nginx.conf /etc/nginx/sites-available/default",
      "sudo nginx -t",

      # Issue certificate
      "sudo certbot --nginx -d aiyusdreamapp.name.ng -d www.aiyusdreamapp.name.ng --non-interactive --agree-tos -m admin@aiyusdreamapp.name.ng",
      "sudo systemctl reload nginx",
      "sudo certbot renew --dry-run",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = aws_instance.ec2.public_ip
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
# Route 53 Records (point directly to EC2 public IP)
# --------------------------
resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "aiyusdreamapp.name.ng"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2.public_ip]
}

resource "aws_route53_record" "frontend_www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.aiyusdreamapp.name.ng"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2.public_ip]
}
