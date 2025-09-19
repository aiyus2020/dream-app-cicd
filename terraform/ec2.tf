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
# EC2 Instance with remote-exec provisioning
# --------------------------
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id # Use Ubuntu 20.04 AMI
  instance_type               = var.instance_type      # Instance type from variables
  subnet_id                   = aws_subnet.main.id     # Launch in created subnet
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id] # Attach EC2 security group
  associate_public_ip_address = true                   # Ensure public IP is assigned
  key_name                    = "terraform-deploy"     # EC2 key pair name for SSH
  depends_on                  = [aws_internet_gateway.main]   # Wait until IGW exists

  # --------------------------
  # Upload nginx.conf file to the instance
  # --------------------------
  provisioner "file" {
    source      = "nginx.conf"   # Local nginx.conf in repo
    destination = "/tmp/nginx.conf" # Upload to EC2 /tmp

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = self.public_ip
    }
  }

  # --------------------------
  # Run commands on the EC2 instance after it boots
  # --------------------------
  provisioner "remote-exec" {
    inline = [
      # Update & upgrade system
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",

      # Install basic dependencies
      "sudo apt install -y jq ca-certificates curl gnupg lsb-release software-properties-common",

      # Add Docker’s official GPG key
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",

      # Add Docker repo to apt sources
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Install Docker + Docker Compose plugin
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      # Enable and start Docker
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      # Add ubuntu user to docker group (so it can run docker without sudo)
      "sudo usermod -aG docker ubuntu",

      # Install Nginx
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",

      # Replace default Nginx config with uploaded file
      "sudo mv /tmp/nginx.conf /etc/nginx/sites-available/default",

      # Validate nginx config and reload
      "sudo nginx -t",
      "sudo systemctl reload nginx",

      # Install Certbot for SSL
      "sudo apt-get install -y certbot python3-certbot-nginx",

      # Request and configure SSL cert for your domain
      "sudo certbot --nginx -d aiyusdreamapp.name.ng --non-interactive --agree-tos -m admin@aiyusdreamapp.name.ng",

      # Allow Nginx ports (80, 443) in UFW (ignore if UFW not enabled)
      "sudo ufw allow 'Nginx Full' || true"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "${var.project_name}-ec2" # Tag instance with project name
  }
}
