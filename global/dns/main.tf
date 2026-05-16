data "aws_route53_zone" "main" {
  name = var.domain_name
  private_zone = false
}


resource "aws_route53_health_check" "primary_alb" {
  fqdn = var.primary_alb_dns_name
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "3"
  request_interval = "30"

  tags = merge(var.tags, { Name = "health-check-${var.primary_region}" })
}

resource "aws_route53_health_check" "secondary_alb" {
  fqdn = var.secondary_alb_dns_name
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "3"
  request_interval = "30"

  tags = merge(var.tags, { Name = "health-check-${var.secondary_region}" })
}


resource "aws_route53_record" "app_primary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "${var.subdomain_name}.${var.domain_name}"
  type = "A"

  # Unique identifier for this record within the routing group
  set_identifier = "active-active-${var.primary_region}"

  latency_routing_policy {
    region = var.primary_region
  }

  alias {
    name = var.primary_alb_dns_name
    zone_id = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary_alb.id
}

# Secondary Region Routing Record
resource "aws_route53_record" "app_secondary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "${var.subdomain_name}.${var.domain_name}"
  type = "A"

  # Unique identifier for this record within the routing group
  set_identifier = "active-active-${var.secondary_region}"

  latency_routing_policy {
    region = var.secondary_region
  }

  alias {
    name = var.secondary_alb_dns_name
    zone_id = var.secondary_alb_zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.secondary_alb.id
}