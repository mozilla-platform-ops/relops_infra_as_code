terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "gcp-taskcluster-imaging.tfstate"
    dynamodb_table = "tf_state_lock_gcp-taskcluster-imaging"
    region         = "us-west-2"
  }
}
