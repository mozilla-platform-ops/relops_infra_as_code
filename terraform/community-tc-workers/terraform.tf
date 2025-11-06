terraform {
  backend "s3" {
    bucket       = "relops-tf-states"
    key          = "community-tc-workers.tfstate"
    use_lockfile = true
    region       = "us-west-2"
  }
}

provider "google" {
  project = local.project
  # not sure what these should be
  region = "us-west1"
  zone   = "us-west1-b"
}

