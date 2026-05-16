variable "aws_region" {
  description = "The AWS region for the DR site (must be different from primary)"
  type = string
  default = "ap-south-1"
}

variable "environment_name" {
  description = "Name of the environment"
  type = string
  default  = "dr"
}

variable "frontend_instance_type" {
  description = "EC2 instance type for DR (keep small until disaster)"
  type = string
}

variable "frontend_min_size" {
  description = "Minimum ASG size (0 for Pilot Light, 1 for Warm Standby)"
  type = number
}

variable "db_instance_class" {
  description = "RDS instance size for DR"
  type = string
}