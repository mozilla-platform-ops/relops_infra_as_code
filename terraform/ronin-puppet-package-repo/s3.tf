resource "aws_s3_bucket" "package_bucket" {
  bucket = "ronin-puppet-package-repo"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::ronin-puppet-package-repo/*"
      ]
    }
  ]
}
POLICY


  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }

  tags = {
    Name = "ronin-puppet-package-repo"
  }
}

# Log bucket for storing access logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "ronin-puppet-package-repo-logs"
  acl    = "log-delivery-write"

  tags = {
    Name = "ronin-puppet-package-repo-logs"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.package_bucket.id
  key    = "index.html"
  source = "files/index.html"
  etag   = filemd5("files/index.html")
}

