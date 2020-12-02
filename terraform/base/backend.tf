terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "base.tfstate"
    dynamodb_table = "tf_state_lock_base"
    region         = "us-west-2"
  }
}

