terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "puppetdb.tfstate"
    dynamodb_table = "tf_state_lock_puppetdb"
    region         = "us-west-2"
  }
}
