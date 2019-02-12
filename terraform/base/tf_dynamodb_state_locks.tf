resource "aws_dynamodb_table" "tf_state_lock_base" {
  name = "tf_state_lock_base"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "Base Terraform State Lock Table"
  }
}

