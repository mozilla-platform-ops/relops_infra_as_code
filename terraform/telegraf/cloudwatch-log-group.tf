resource "aws_cloudwatch_log_group" "telegraf" {
  name = "telegraf"

  retention_in_days = 14

  tags = {
    Terraform   = "true"
    Repo_url    = var.repo_url
    Environment = "Prod"
    Owner       = "relops@mozilla.com"
  }
}
