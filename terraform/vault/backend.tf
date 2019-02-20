terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "vault.tfstate"
    dynamodb_table = "tf_state_lock_vault"
    region         = "us-west-2"
  }
}
