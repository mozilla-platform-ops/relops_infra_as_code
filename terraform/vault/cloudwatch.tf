resource "aws_cloudwatch_log_group" "vault" {
  name = "vault"

  retention_in_days = 90

  tags = merge(local.common_tags,
    tomap({
      "Name" = "vault"
    })
  )
}
