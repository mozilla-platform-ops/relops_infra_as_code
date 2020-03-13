terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "maas.tfstate"
    dynamodb_table = "tf_state_lock_maas"
    region         = "us-west-2"
  }
}
