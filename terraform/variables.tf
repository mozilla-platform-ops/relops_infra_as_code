# This file contains empty declarations for variables that will be definied in each
# environments terraform.tfvars file

variable "region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "tag_project_name" {
  description = "Name of the project; should match dir name"

  # No default; must be set in terraform.tfvars
}

variable "tag_production_state" {
  description = "Production Tier: dev, stage, production"

  # Default to dev
  default = "dev"
}

variable "tag_owner_email" {
  description = "Email address of project owner"

  # Should be set to primary project owner
  default = "relops@mozilla.com"
}

# TODO: remove this
variable "repo_url" {
  description = "A link to this github repo"
  default     = "https://github.com/mozilla-platform-ops/relops_cloud"
}
