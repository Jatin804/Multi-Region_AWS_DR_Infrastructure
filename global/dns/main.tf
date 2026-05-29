data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ------------------------------------------------------------------------------
# Primary Region Active-Active Record
# ------------------------------------------------------------------------------
resource "aws_route53_record" "app_primary" {
  zone_id = data.aws_route53_zone.main.zone_id
  
  # Gracefully handles empty subdomains for root domain deployments
  name    = var.subdomain_name != "" ? "${var.subdomain_name}.${var.domain_name}" : var.domain_name
  type    = "A"

  set_identifier = "active-active-${var.primary_region}"

  latency_routing_policy {
    region = var.primary_region
  }

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    # Native integration replaces the need for separate health check resources
    evaluate_target_health = true 
  }
}

# ------------------------------------------------------------------------------
# Secondary Region Active-Active Record
# ------------------------------------------------------------------------------
resource "aws_route53_record" "app_secondary" {
  zone_id = data.aws_route53_zone.main.zone_id
  
  name    = var.subdomain_name != "" ? "${var.subdomain_name}.${var.domain_name}" : var.domain_name
  type    = "A"

  set_identifier = "active-active-${var.secondary_region}"

  latency_routing_policy {
    region = var.secondary_region
  }

  alias {
    name                   = var.secondary_alb_dns_name
    zone_id                = var.secondary_alb_zone_id
    # Native integration replaces the need for separate health check resources
    evaluate_target_health = true
  }
}