# Existing IAM principal used by FirefoxCI Taskcluster worker-manager to
# provision AWS workers. Access keys are intentionally managed out of band so
# long-lived secrets are not stored in Terraform state. Tags are ignored because
# this resource predates this Terraform module.
resource "aws_iam_user" "taskcluster_worker_manager" {
  name          = var.taskcluster_worker_manager_user_name
  force_destroy = false

  lifecycle {
    ignore_changes = [
      force_destroy,
      tags,
      tags_all,
    ]
  }
}

data "aws_iam_policy_document" "taskcluster_worker_manager" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeInstanceStatus",
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "taskcluster_worker_manager" {
  name        = var.taskcluster_worker_manager_policy_name
  description = "Per the TC docs"
  policy      = data.aws_iam_policy_document.taskcluster_worker_manager.json

  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
    ]
  }
}

resource "aws_iam_user_policy_attachment" "taskcluster_worker_manager" {
  user       = aws_iam_user.taskcluster_worker_manager.name
  policy_arn = aws_iam_policy.taskcluster_worker_manager.arn
}
