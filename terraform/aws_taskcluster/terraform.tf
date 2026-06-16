terraform {
  backend "s3" {
    bucket       = "relops-tf-states"
    key          = "aws_taskcluster.tfstate"
    use_lockfile = true
    region       = "us-west-2"
  }

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
