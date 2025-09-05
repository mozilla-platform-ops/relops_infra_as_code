terraform {
  backend "s3" {
    bucket       = "relops-tf-states"
    key          = "azure_monitor.tfstate"
    use_lockfile = true
    region       = "us-west-2"
  }
}
