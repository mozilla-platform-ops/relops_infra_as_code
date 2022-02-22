terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_fx_nonci.tfstate"
    dynamodb_table = "tf_state_lock_azure_fx_nonci"
    region         = "us-west-2"
  }
}
