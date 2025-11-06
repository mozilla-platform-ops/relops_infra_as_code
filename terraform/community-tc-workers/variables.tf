variable "oidc_github_repositories" {
  type        = set(string)
  description = "Owner/Repository for configuring OIDC"
}

variable "group_project_owners" {
  type        = list(string)
  description = "List of email addresses to be assigned the Owner role"
}