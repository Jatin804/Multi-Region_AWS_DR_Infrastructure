terraform {
  # 1. Remote State Backend Configuration
  backend "s3" {
    bucket  = "your-unique-company-tf-state-bucket"
    key     = "project-active-active/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }

  # 2. Provider Requirements
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.43.0"
    }
  }
}