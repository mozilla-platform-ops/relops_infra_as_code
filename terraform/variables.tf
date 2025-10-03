# This file contains empty declarations for variables that will be definied in each
# environments terraform.tfvars file

## TODO: review these vars
## They are old and may not be in use

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

## KEEP/NEWER
# Subscription IDs
variable "fxci_devtest_subscription_id" {
  description = "FXCI Azure DevTest Subscription ID"
  type        = string
}

variable "taskcluster_subscription_id" {
  description = "Taskcluster Engineering DevTest Subscription ID"
  type        = string
}

variable "trusted_fxci_subscription_id" {
  description = "Trusted FXCI Azure DevTest Subscription ID"
  type        = string
}

variable "infra_sec_subscription_id" {
  description = "Mozilla Infrastructure Security Subscription ID"
  type        = string
}

variable "firefox_nonci_subscription_id" {
  description = "Firefox Non-CI DevTest Subscription ID"
  type        = string
}

variable "zero_din_subscription_id" {
  description = "Mozilla ODIN Subscription ID"
  type        = string
}

# Group membership variables
variable "zero_din_group" {
  description = "List of UPNs for the 0DIN group membership."
  type        = list(string)
  default     = []
}
