terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_trusted_fxci.tfstate"
    dynamodb_table = "tf_state_lock_azure_fxci"
    region         = "us-west-2"
  }
}
