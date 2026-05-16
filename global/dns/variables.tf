variable "domain_name" {
  description = "The top-level domain name (e.g., example.com)"
  type = string
}

variable "subdomain_name" {
  description = "The specific application subdomain (e.g., app.example.com or www.example.com)"
  type = string
  default = "www"
}

variable "primary_region" {
  description = "The AWS region of the primary site (e.g., us-east-1)"
  type = string
}

variable "primary_alb_dns_name" {
  description = "DNS name of the primary Application Load Balancer"
  type = string
}

variable "primary_alb_zone_id" {
  description = "Hosted zone ID of the primary Application Load Balancer"
  type = string
}

variable "secondary_region" {
  description = "The AWS region of the secondary site (e.g., us-west-2)"
  type = string
}

variable "secondary_alb_dns_name" {
  description = "DNS name of the secondary Application Load Balancer"
  type = string
}

variable "secondary_alb_zone_id" {
  description = "Hosted zone ID of the secondary Application Load Balancer"
  type = string
}

variable "tags" {
  description = "Common tags for global resources"
  type = map(string)
}