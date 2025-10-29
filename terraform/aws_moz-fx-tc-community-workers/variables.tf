variable "oidc_github_repositories" {
  type        = set(string)
  description = "List of GitHub repositories (format: owner/repo) allowed to assume the IAM role via OIDC"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-west-2"
}
