resource "aws_s3_bucket" "state_bucket" {
  bucket = "relops-tf-states"
  acl    = "private"

  versioning {
    enabled = true
  }
}
