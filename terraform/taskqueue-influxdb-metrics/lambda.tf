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

resource "aws_lambda_function" "log_bitbar_data_to_influx" {
  filename         = "function.zip"
  function_name    = "bitbar_influx_logger"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "function.lambda_handler"
  source_code_hash = "${base64sha256(file("function.zip"))}"
  runtime          = "python3.6"
}
