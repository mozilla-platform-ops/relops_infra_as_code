terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "azure_mr2_app.tfstate"
    dynamodb_table = "tf_state_lock_azure_mr2_app"
    region         = "us-west-2"
  }
}
