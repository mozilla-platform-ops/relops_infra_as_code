terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "gcp-fxci-production-level1-workers.tfstate"
    dynamodb_table = "tf_state_lock_gcp-fxci-production-level1-workers"
    region         = "us-west-2"
  }
}
