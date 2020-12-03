resource "aws_dynamodb_table" "dynamodb-table" {
  name         = "vault"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Path"
  range_key    = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = merge(local.common_tags,
    map(
      "Name", "vault-dynamodb-table"
    )
  )
}

data "aws_iam_policy_document" "vault_dynamodb_access" {
  statement {
    effect    = "Allow"
    resources = [aws_dynamodb_table.dynamodb-table.arn]

    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]
  }
}

resource "aws_iam_policy" "vault_dynamodb_policy" {
  name   = "Vault-DynamoDB-Policy"
  policy = data.aws_iam_policy_document.vault_dynamodb_access.json
}

resource "aws_iam_role_policy_attachment" "ecs-instance-dynamodb-role-attachment" {
  role       = aws_iam_role.ecs-task-role.name
  policy_arn = aws_iam_policy.vault_dynamodb_policy.arn
}
