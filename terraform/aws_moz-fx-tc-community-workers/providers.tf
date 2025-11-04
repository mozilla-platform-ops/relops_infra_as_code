terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = "AdministratorAccess-885316786408"  # Profile for deployment account
  allowed_account_ids = ["885316786408"]
}
