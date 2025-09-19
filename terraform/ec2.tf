# --------------------------
# Get the latest Ubuntu 20.04 AMI
# --------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# --------------------------
# EC2 Instance
# --------------------------
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  key_name               = "terraform-deploy"

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [aws_internet_gateway.main]
}

# --------------------------
# Existing Elastic IP
# --------------------------
data "aws_eip" "existing_eip" {
  public_ip = var.elastic_ip
}

# --------------------------
# Associate Elastic IP
# --------------------------
resource "aws_eip_association" "ec2_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = data.aws_eip.existing_eip.id
}

# --------------------------
# Route53 Zone
# --------------------------
data "aws_route53_zone" "main" {
  name         = "aiyusdreamapp.name.ng"
  private_zone = false
}

# --------------------------
# Route53 Records
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
