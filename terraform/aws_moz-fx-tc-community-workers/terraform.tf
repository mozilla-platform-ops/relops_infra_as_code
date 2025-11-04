terraform {
  backend "s3" {
    bucket       = "relops-tf-states"
    key          = "aws_moz-fx-tc-community-workers.tfstate"
    use_lockfile = true
    region       = "us-west-2"
    profile      = "AdministratorAccess-961225894672"
  }
}

