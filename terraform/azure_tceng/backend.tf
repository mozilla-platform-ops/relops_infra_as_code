terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_tceng.tfstate"
    dynamodb_table = "tf_state_lock_azure_fx_tceng"
    region         = "us-west-2"
  }
}
