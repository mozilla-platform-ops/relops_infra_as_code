terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "puppetagain_ca_codecommit.tfstate"
    dynamodb_table = "tf_state_lock_puppetagain_ca_codecommit"
    region         = "us-west-2"
  }
}

