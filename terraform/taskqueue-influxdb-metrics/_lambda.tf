### iam policies, attachments, and role

resource "aws_iam_policy" "secretsmanager-influx" {
  name        = "secretsmanager-influx"
  description = "Allows access to influxdb secretsmanager secret."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "arn:aws:secretsmanager:us-west-2:961225894672:secret:influxdb_credentials-hGl99p"
    }
}
EOF
}

resource "aws_iam_policy_attachment" "secretsmanager_to_influx" {
  name       = "secretsmanager_to_influx"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.secretsmanager-influx.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

### lambda function and permissions

resource "aws_lambda_function" "bitbar_influx_logger" {
  filename         = "function.zip"
  function_name    = "bitbar_influx_logger"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "function.lambda_handler"
  source_code_hash = filebase64sha256("function.zip")
  runtime          = "python3.8"
  timeout          = 60
}

# Allow cloudwatch to trigger the lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bitbar_influx_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tick_1m.arn
}
