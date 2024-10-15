variable "oidc_github_repositories" {
  type = set(string)
  description = "Owner/Repository for configuring OIDC"
}

variable "releng_users" {
    type = set(string)
    description = "list of usernames"
}

variable "translations_users" {
    type = set(string)
    description = "list of usernames"
}

variable "read_only_users" {
    type = set(string)
    description = "list of usernames"
}