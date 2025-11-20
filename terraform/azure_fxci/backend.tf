terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_fxci.tfstate"
    use_lockfile = true
    region         = "us-west-2"
  }
}
