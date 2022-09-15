terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "ronin-puppet-assets.tfstate"
    dynamodb_table = "tf_state_lock_ronin-puppet-assets"
    region         = "us-west-2"
  }
}
