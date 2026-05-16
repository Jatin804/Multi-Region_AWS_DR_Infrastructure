
variable "aws_vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
}

variable "availability_zones" {
    description = "List of availabilty zones"
    type = list(string)
}

variable "public_subnet_cidr" {
    description = "Public subnets CIDR blocks"
    type = list(string)
}

variable "private_subnet_cidr" {
    description = "Private subnet CIDR blocks"
    type = list(string)
}

variable "nat_availability_mode" {
    description = "NAT gateway availability_mode"
    type = string
    default = "zonal"
}

variable "vpc_endpoint" {
    description = "VPC endpoint"
    type = bool
    default = false
}

variable "route_cidr" {
    description = "gateway subnet"
    type = string  
}

variable "tags" {
  description = "Common Tags"
  type = map(string)
#   default = {
#     Environment = "dev"
#     Project = "web-site"
#     Managed_by = "terraform"
#   }
}