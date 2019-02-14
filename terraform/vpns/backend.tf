terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "vpns.tfstate"
    dynamodb_table = "tf_state_lock_vpns"
    region         = "us-west-2"
  }
}
