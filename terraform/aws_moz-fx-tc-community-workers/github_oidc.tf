# This Terraform configuration file's goal is to assign IAM roles to GitHub Actions.

# Fetch GitHub's OIDC provider certificate thumbprint dynamically
# This is required by AWS to verify the OIDC provider's identity
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create the GitHub OIDC provider
# Note: Only one OIDC provider per URL can exist in an AWS account
# If you already have a GitHub OIDC provider, import it with:
# terraform import aws_iam_openid_connect_provider.github_actions arn:aws:iam::885316786408:oidc-provider/token.actions.githubusercontent.com
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "github-actions-oidc"
    Project     = "aws_moz-fx-tc-community-workers"
    Environment = "production"
  }
}

# IAM policy for Packer permissions
data "aws_iam_policy_document" "github_actions_packer" {
  statement {
    sid    = "PackerEC2Permissions"
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_packer" {
  name        = "GitHubActionsPackerPolicy"
  description = "Policy for GitHub Actions to run Packer for AMI creation"
  policy      = data.aws_iam_policy_document.github_actions_packer.json

  tags = {
    Name        = "github-actions-packer-policy"
    Project     = "aws_moz-fx-tc-community-workers"
    Environment = "production"
  }
}

# IAM role that GitHub Actions will assume
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Allow main branch pushes and prod environment deployments
      values   = flatten([
        for repo in var.oidc_github_repositories : [
          "repo:${repo}:ref:refs/heads/main",
          "repo:${repo}:environment:prod"
        ]
      ])
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "IAM role for GitHub Actions to authenticate via OIDC"

  tags = {
    Name        = "github-actions-role"
    Project     = "aws_moz-fx-tc-community-workers"
    Environment = "production"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_packer" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_packer.arn
}

# Output the role ARN for use in GitHub Actions workflows
output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
