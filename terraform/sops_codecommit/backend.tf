terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "sops_codecommit.tfstate"
    dynamodb_table = "tf_state_lock_sops_codecommit"
    region         = "us-west-2"
  }
}

