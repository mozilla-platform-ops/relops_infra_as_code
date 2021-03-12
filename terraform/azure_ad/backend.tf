terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_ad.tfstate"
    dynamodb_table = "tf_state_lock_azure_ad"
    region         = "us-west-2"
  }
}
