variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = number
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "dream"
}
 variable "destination_cidr_block" {
   description = "value for destination_cidr_block in route"
   type        = number
 }
 variable "key_name" {
    description = "Name of the existing key pair to use for EC2 instance"
    type        = string
    default     = "ken" 
 }