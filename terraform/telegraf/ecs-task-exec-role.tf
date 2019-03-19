data "aws_iam_policy_document" "ecs-task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-task-exec-role" {
  name               = "telegraf-ecs-task-exec-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-task-assume-role-policy.json}"
}

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "telegraf-SSMAllow"
  description = "Allow telegraf to read from ssm"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:us-west-2:961225894672:parameter/influx*",
        "arn:aws:ssm:us-west-2:961225894672:parameter/telegraf*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = "${aws_iam_role.ecs-task-exec-role.name}"
  policy_arn = "${aws_iam_policy.secrets_read_policy.arn}"
}
