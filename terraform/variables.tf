# This file contains empty declarations for variables that will be definied in each
# environments terraform.tfvars file

variable "region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "repo_url" {
  description = "A link to this github repo"
  default     = "https://github.com/mozilla-platform-ops/relops_cloud"
}
