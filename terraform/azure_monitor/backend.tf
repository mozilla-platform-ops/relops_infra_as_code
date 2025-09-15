terraform {
  backend "s3" {
    bucket = "relops-tf-states"
    key    = "azure_monitor.tfstate"
    region = "us-west-2"

    # Optional: enable state locking with DynamoDB
    # dynamodb_table = "tf_state_lock_azure_monitor"
  }
}
