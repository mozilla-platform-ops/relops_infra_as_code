data "aws_iam_policy_document" "ecs-task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-task-role" {
  name               = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-assume-role-policy.json
}
