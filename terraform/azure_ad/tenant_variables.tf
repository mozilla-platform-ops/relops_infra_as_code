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

variable "relops_group" {
  description = "List of UPNs for the Relops group membership."
  type        = list(string)
  default     = []
}

variable "releng_group" {
  description = "List of UPNs for the Releng group membership."
  type        = list(string)
  default     = []
}

variable "tceng_group" {
  description = "List of UPNs for the Taskcluster group membership."
  type        = list(string)
  default     = []
}

variable "infrasec_group" {
  description = "List of UPNs for the Infrastructure Security Team group membership."
  type        = list(string)
  default     = []
}

variable "ci_billing_group" {
  description = "List of UPNs for the CI Billing group membership."
  type        = list(string)
  default     = []
}

variable "windows_testers_group" {
  description = "List of UPNs for the WindowsTesters group membership."
  type        = list(string)
  default     = []
}

variable "firefox_enterprise_vms_group" {
  description = "List of UPNs for the Firefox Enterprise VMs group membership."
  type        = list(string)
  default     = []
}

variable "firefox_desktop_vms_group" {
  description = "List of UPNs for the Firefox Desktop VMs group membership."
  type        = list(string)
  default     = []
}

variable "security_engineering_group" {
  description = "List of UPNs for the Security Engineering group membership."
  type        = list(string)
  default     = []
}

variable "cognitive_services_group" {
  description = "List of UPNs for the Cognitive Services group membership."
  type        = list(string)
  default     = []
}

variable "data_sre_group" {
  description = "List of UPNs for the Data SRE group membership."
  type        = list(string)
  default     = []
}

variable "passkey_poc_group" {
  description = "List of UPNs for the Passkey_PoC group membership."
  type        = list(string)
  default     = []
}

variable "macos_windows_sso_testing_group" {
  description = "List of UPNs for the macOS Windows SSO Testing group membership."
  type        = list(string)
  default     = []
}

variable "service_desk_group" {
  description = "List of UPNs for the Service Desk group membership."
  type        = list(string)
  default     = []
}

variable "webrtc_group" {
  description = "List of UPNs for the WebRTC Group membership."
  type        = list(string)
  default     = []
}

variable "policy_testing_group" {
  description = "List of UPNs for the Policy Testing group membership."
  type        = list(string)
  default     = []
}

variable "seio_group" {
  description = "List of UPNs for the SEIO group membership."
  type        = list(string)
  default     = []
}

variable "ms_store_publishers_group" {
  description = "List of UPNs for the Microsoft Store Publishers group membership."
  type        = list(string)
  default     = []
}

variable "ms_store_finance_group" {
  description = "List of UPNs for the Microsoft Store Finance group membership."
  type        = list(string)
  default     = []
}
