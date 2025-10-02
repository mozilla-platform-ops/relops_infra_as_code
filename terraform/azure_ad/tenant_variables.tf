# Subscription IDs (one var per subscription)
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
  description = "Mozilla 0DIN Subscription ID"
  type        = string
}

# Group membership for 0DIN
variable "zero_din_group" {
  description = "List of UPNs for the 0DIN group membership."
  type        = list(string)
  default     = []
}
