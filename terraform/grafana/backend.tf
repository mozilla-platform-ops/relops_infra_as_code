terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "grafana.tfstate"
    dynamodb_table = "tf_state_lock_grafana"
    region         = "us-west-2"
  }
}
