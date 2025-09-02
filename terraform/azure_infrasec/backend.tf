terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_infrasec.tfstate"
    dynamodb_table = "tf_state_lock_azure_infrasec"
    region         = "us-west-2"
  }
}
