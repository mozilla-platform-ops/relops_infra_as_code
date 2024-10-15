terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "gcp-fxci-production-level3-workers.tfstate"
    dynamodb_table = "tf_state_lock_gcp-fxci-production-level3-workers"
    region         = "us-west-2"
  }
}
