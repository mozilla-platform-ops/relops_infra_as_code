terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "vault_config.tfstate"
    dynamodb_table = "tf_state_lock_vault_config"
    region         = "us-west-2"
  }
}
