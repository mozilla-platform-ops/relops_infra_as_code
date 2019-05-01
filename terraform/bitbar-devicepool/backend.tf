terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "bitbar-devicepool.tfstate"
    dynamodb_table = "tf_state_lock_bitbar-devicepool"
    region         = "us-west-2"
  }
}
