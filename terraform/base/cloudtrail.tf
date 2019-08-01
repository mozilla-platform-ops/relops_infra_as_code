# Creates a cloudtrail for sending aws logs to firefox security for auditing

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "cloudtrail-to-foxsec"
  s3_bucket_name                = "moz-cloudtrail-logs"
  s3_key_prefix                 = "relops-aws-prod"
  include_global_service_events = true
  is_multi_region_trail         = true

  tags = {
    Name = "cloudtrail-to-foxsec"
    bug  = "1531162"
  }
}
