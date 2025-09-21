output "vpc_id" {
    description = "value for vpc_id"
  value = aws_vpc.main.id
}

output "subnet_id" {
  description = "value for subnet_id"
  value = aws_subnet.main.id
}



output "ec2_public_dns" {
  description = "value for ec2_public_dns"
  value = aws_instance.ec2.public_dns
}
output "ec2_public_ip" {
  value = data.aws_eip.existing_eip.public_ip
}

output "ssh_output" {
  value = "ssh -i ${var.key_name}.pem ubuntu@${data.aws_eip.existing_eip.public_ip}"
}





