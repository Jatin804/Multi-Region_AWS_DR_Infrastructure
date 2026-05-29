variable "aws_region" {
  description = "The AWS region to deploy into (e.g., us-east-1 for Primary, us-west-2 for DR)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment name for tagging (e.g., prod-primary, prod-dr)"
  type        = string
  default     = "prod-primary"
}

variable "aws_vpc_cidr" {
  description = "The CIDR block for the VPC. Ensure this does NOT overlap between Primary and DR regions."
  type        = string
  default     = "10.1.0.0/16" 
}

variable "availability_zones" {
  description = "A list of Availability Zones to deploy into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidr" {
  description = "A map of AZs to Public Subnet CIDRs"
  type        = map(string)
  default = {
    "us-east-1a" = "10.1.1.0/24"
    "us-east-1b" = "10.1.2.0/24"
  }
}

variable "private_subnet_cidr" {
  description = "A map of AZs to Private Subnet CIDRs"
  type        = map(string)
  default = {
    "us-east-1a" = "10.1.10.0/24"
    "us-east-1b" = "10.1.20.0/24"
  }
}

variable "route_cidr" {
  description = "The default route CIDR for internet bound traffic"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Multi-Region-DR"
  }
}