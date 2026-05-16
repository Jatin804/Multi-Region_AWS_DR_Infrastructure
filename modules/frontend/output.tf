output "frontend_alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value = aws_lb.frontend_alb.dns_name
}

output "frontend_alb_zone_id" {
  description = "The Zone ID of the Application Load Balancer (used for Route53 Alias records)"
  value = aws_lb.frontend_alb.zone_id
}