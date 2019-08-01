data "aws_route53_zone" "relops_mozops_net" {
  name = "relops.mozops.net."
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket         = "relops-tf-states"
    key            = "base.tfstate"
    dynamodb_table = "tf_state_lock_base"
    region         = "us-west-2"
  }
}
