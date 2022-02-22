resource "aws_dynamodb_table" "tf_state_lock_azure_fx_nonci" {
  name           = "tf_state_lock_azure_fx_nonci"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "azure_fx_nonci Terraform State Lock Table"
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "prod"
    Owner       = "relops@mozilla.com"
  }
}
