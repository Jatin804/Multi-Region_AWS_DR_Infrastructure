# Root main.tf

module "primary_infrastructure" {
  source = "./environments/primary"
  providers = {
    aws = aws.primary
  }
}

module "secondary_infrastructure" {
  source = "./environments/secondary"
  providers = {
    aws = aws.secondary
  }
}

module "global_dns" {
  source = "./global/dns"
  
  domain_name             = "yourcompany.com"
  subdomain_name          = "app"
  
  primary_region          = "us-east-1"
  primary_alb_dns_name    = module.primary_infrastructure.alb_dns_name
  primary_alb_zone_id     = module.primary_infrastructure.alb_zone_id
  
  secondary_region        = "us-west-2"
  secondary_alb_dns_name  = module.secondary_infrastructure.alb_dns_name
  secondary_alb_zone_id   = module.secondary_infrastructure.alb_zone_id

  tags = { Environment = "production", ManagedBy = "Terraform" }
}