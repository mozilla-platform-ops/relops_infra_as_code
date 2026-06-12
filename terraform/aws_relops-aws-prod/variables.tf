variable "oidc_github_repositories" {
  type        = set(string)
  description = "List of GitHub repositories (format: owner/repo) allowed to assume the IAM role via OIDC"
  default     = ["mozilla-platform-ops/worker-images", "mozilla-platform-ops/monopacker"]
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-west-2"
}

