resource "aws_s3_bucket" "state_bucket" {
  bucket = "relops-tf-states"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}

