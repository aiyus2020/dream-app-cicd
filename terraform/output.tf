output "vpc_id" {
  description = "value for vpc_id"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "value for subnet_id"
  value       = aws_subnet.main.id
}

output "ec2_public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.ec2.public_dns
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.ec2.public_ip
}

output "ssh_output" {
  value = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.ec2.public_ip}"
}
