provider "aws" {
  region = var.aws_region

  # PRO TIP: Define tags at the provider level so you don't have to 
  # manually pass them into every single module. AWS will auto-apply them.
  default_tags {
    tags = {
      Environment = var.environment_name
      Project     = "Multi-Region-DR"
      ManagedBy   = "Terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. Network Module (Fixed for Map Variables)
# ------------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  aws_vpc_cidr       = "10.1.0.0/16" 
  availability_zones = ["us-west-1b", "us-west-1c"]
  
  # Upgraded to maps to match the for_each logic in the network module
  public_subnet_cidr = {
    "us-west-1b" = "10.1.1.0/24"
    "us-west-1c" = "10.1.2.0/24"
  }
  
  private_subnet_cidr = {
    "us-west-1b" = "10.1.3.0/24"
    "us-west-1c" = "10.1.4.0/24"
  }
}

# ------------------------------------------------------------------------------
# 2. Frontend Module (Dynamic AMI Resolution)
# ------------------------------------------------------------------------------
# Fetch the latest Amazon Linux AMI dynamically for whichever region this runs in
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-kernel-*-x86_64"]
  }
}

module "frontend" {
  source = "../../modules/frontend"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  
  instance_type = var.frontend_instance_type
  min_size      = var.frontend_min_size 
  
  # Passes the dynamically resolved AMI ID
  ami_id        = data.aws_ami.amazon_linux.id 
}

# ------------------------------------------------------------------------------
# 3. Backend Module
# ------------------------------------------------------------------------------
module "backend" {
  source = "../../modules/backend"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  
  # Warning: Keep an eye out for circular dependencies here if your 
  # frontend ever requires database outputs!
  frontend_sg_id     = module.frontend.ec2_security_group_id
  
  db_instance_class  = var.db_instance_class
}