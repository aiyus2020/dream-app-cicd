output "vpc_id" {
    description = "value for vpc_id"
  value = aws_vpc.main.id
}

output "subnet_id" {
  description = "value for subnet_id"
  value = aws_subnet.main.id
}

output "ec2_public_ip" {
  description = "value for ec2_public_ip"
  value = aws_instance.ec2.public_ip
}

output "ec2_public_dns" {
  description = "value for ec2_public_dns"
  value = aws_instance.ec2.public_dns
}
output "ssh_output" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.ec2.public_ip}"
}

output "ec2_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
