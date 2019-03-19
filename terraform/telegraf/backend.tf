terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "telegraf.tfstate"
    dynamodb_table = "tf_state_lock_telegraf"
    region         = "us-west-2"
  }
}
