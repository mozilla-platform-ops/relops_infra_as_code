variable "aws_account_id" {
  type        = string
  description = "AWS account ID for the Taskcluster worker account"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile for the Taskcluster worker account"
}

variable "aws_region" {
  type        = string
  description = "Default AWS region for global IAM resources"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment tag value"
  default     = "production"
}

variable "github_actions_packer_policy_name" {
  type        = string
  description = "IAM policy name for GitHub Actions Packer builds"
  default     = "GitHubActionsPackerPolicy"
}

variable "github_actions_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions OIDC"
  default     = "GitHubActionsRole"
}

variable "github_oidc_audience" {
  type        = string
  description = "GitHub OIDC audience accepted by AWS STS"
  default     = "sts.amazonaws.com"
}

variable "github_oidc_url" {
  type        = string
  description = "GitHub Actions OIDC issuer URL"
  default     = "https://token.actions.githubusercontent.com"
}

variable "oidc_github_repositories" {
  type        = set(string)
  description = "List of GitHub repositories (format: owner/repo) allowed to assume the IAM role via OIDC"
}

variable "project_name" {
  type        = string
  description = "Project tag value"
  default     = "aws-taskcluster"
}

variable "taskcluster_worker_manager_policy_name" {
  type        = string
  description = "IAM policy name for Taskcluster worker-manager"
  default     = "taskcluster-worker-manager"
}

variable "taskcluster_worker_manager_user_name" {
  type        = string
  description = "IAM user name for FirefoxCI Taskcluster worker-manager"
  default     = "firefox-ci-taskcluster-worker-manager"
}
