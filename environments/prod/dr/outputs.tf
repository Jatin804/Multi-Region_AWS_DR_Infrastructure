output "dr_alb_dns_name" {
  description = "The DNS name of the DR Application Load Balancer"
  value = module.frontend.frontend_alb_dns_name
}

output "dr_alb_zone_id" {
  description = "The Zone ID of the DR Application Load Balancer"
  value = module.frontend.frontend_alb_zone_id
}

output "dr_rds_endpoint" {
  description = "The connection endpoint for the DR database"
  value = module.backend.rds_endpoint
}