terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "community-tc-workers.tfstate"
    use_lockfile   = true
    region         = "us-west-2"
  }
}
