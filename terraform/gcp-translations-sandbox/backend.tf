terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "gcp-translations-sandbox.tfstate"
    dynamodb_table = "tf_state_lock_gcp-translations-sandbox"
    region         = "us-west-2"
  }
}
