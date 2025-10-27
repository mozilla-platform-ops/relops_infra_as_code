terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "gcp-taskcluster-imaging.tfstate"
    use_lockfile = true
    region         = "us-west-2"
  }
}
