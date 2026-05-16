provider "aws" {
  region = var.aws_region
}

# 1. Deploy the DR Network
module "network" {
  source = "../../modules/network"

  # Use a different CIDR than Primary to allow for VPC Peering if needed
  aws_vpc_cidr       = "10.1.0.0/16" 
  public_subnet_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones = ["us-west-1b", "us-west-1c"]
  
  tags = { Environment = var.environment_name }
}

# 2. Deploy the DR Backend (Storage & DB)
module "backend" {
  source = "../../modules/backend"

  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  frontend_sg_id = module.frontend.ec2_security_group_id
  
  # In a true DR, this RDS instance would be a Cross-Region Read Replica 
  # of your primary database, rather than a standalone instance.
  db_instance_class = var.db_instance_class
  
  tags = { Environment = var.environment_name }
}

# 3. Deploy the DR Frontend (Compute)
module "frontend" {
  source = "../../modules/frontend"

  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  
  # Uses the variables from terraform.tfvars to stay scaled down
  instance_type = var.frontend_instance_type
  min_size = var.frontend_min_size 
  
  ami_id = "ami-0abcdef1234567890" # Make sure to use the AMI for the DR region
  tags = { Environment = var.environment_name }
}