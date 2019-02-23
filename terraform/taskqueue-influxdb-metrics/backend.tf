terraform {
  backend "s3" {
    bucket         = "relops-tf-states"
    key            = "taskqueue-influxdb-metrics.tfstate"
    dynamodb_table = "tf_state_lock_taskqueue-influxdb-metrics"
    region         = "us-west-2"
  }
}
