resource "aws_dynamodb_table" "tf_state_lock_gcp-taskcluster-imaging" {
  name           = "tf_state_lock_gcp-taskcluster-imaging"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "gcp-taskcluster-imaging Terraform State Lock Table"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}
