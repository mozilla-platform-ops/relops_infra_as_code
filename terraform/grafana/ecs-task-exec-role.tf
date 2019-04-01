data "aws_iam_policy_document" "ecs-task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-task-exec-role" {
  name               = "grafana-ecs-task-exec-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs-task-assume-role-policy.json}"
}

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "grafana-SSMAllow"
  description = "Allow grafana to read from ssm"

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
        "arn:aws:ssm:us-west-2:961225894672:parameter/grafana_*"
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
