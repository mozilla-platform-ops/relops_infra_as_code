terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_fx_nonci.tfstate"
    use_lockfile = true
    region         = "us-west-2"
  }
}
