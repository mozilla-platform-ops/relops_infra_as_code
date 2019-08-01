provider "aws" {
  version             = "~> 2.0"
  allowed_account_ids = ["961225894672"]
  region              = "${var.region}"
}

provider "aws" {
  version             = "~> 2.0"
  allowed_account_ids = ["961225894672"]
  alias               = "us-east-1"
  region              = "us-east-1"
}

provider "aws" {
  version             = "~> 2.0"
  allowed_account_ids = ["961225894672"]
  alias               = "us-west-2"
  region              = "us-west-2"
}
