variable "vpc_id" {
  description = "The ID of the VPC from the network module"
  type = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EC2 Auto Scaling Group"
  type = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type = map(string)
}

variable "instance_type" {
  description = "EC2 instance type for the frontend application"
  type = string
  default = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the Launch Template"
  type = string
}