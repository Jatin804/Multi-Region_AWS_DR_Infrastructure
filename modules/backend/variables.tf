variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC from the network module"
  type = string
}

variable "dr_region" {
  description = "The AWS region where the disaster recovery resources will be deployed"
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS Subnet Group"
  type = list(string)
}

variable "frontend_sg_id" {
  description = "Security Group ID of the frontend EC2 instances to allow DB access"
  type = string
}

variable "tags" {
  description = "Common tags for all resources"
  type  = map(string)
}

variable "db_username" {
  description = "Username for the RDS instance"
  type = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS instance"
  type = string
  sensitive = true
}