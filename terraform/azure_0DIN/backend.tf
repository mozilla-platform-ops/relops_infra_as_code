terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_0din.tfstate"
    use_lockfile = true
    region         = "us-west-2"
  }
}
