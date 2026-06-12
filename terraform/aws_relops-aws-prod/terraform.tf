terraform {
  backend "s3" {
    bucket       = "relops-tf-states"
    key          = "aws_relops-aws-prod.tfstate"
    use_lockfile = true
    region       = "us-west-2"
    profile      = "AdministratorAccess-961225894672"
  }
}
