terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "ronin-puppet-package-repo.tfstate"
    dynamodb_table = "tf_state_lock_ronin-puppet-package-repo"
    region         = "us-west-2"
  }
}

