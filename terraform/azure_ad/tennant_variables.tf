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
