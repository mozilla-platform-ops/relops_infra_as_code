############################
# Core
############################
variable "name" {
  description = "Short base name used to prefix LAW, DCR, alerts, etc."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for LAW, DCR, Action Group, and alerts."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

############################
# Log Analytics Workspace
############################
variable "law_sku" {
  description = "Log Analytics Workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "law_retention_days" {
  description = "Retention in days for LAW."
  type        = number
  default     = 30
}

############################
# Data Collection Rule (AMA)
############################
variable "session_host_vm_ids" {
  description = "List of session host VM resource IDs to associate with the DCR."
  type        = list(string)
  default     = []
}

variable "perf_sample_seconds" {
  description = "Sampling frequency (seconds) for performance counters."
  type        = number
  default     = 60
}

variable "extra_perf_counters" {
  description = "Additional performance counters to collect."
  type        = list(string)
  default     = []
}

variable "extra_event_log_xpaths" {
  description = "Additional Windows Event Log XPath queries."
  type        = list(string)
  default     = []
}

############################
# Alerts / Action Group
############################
variable "enable_alerts" {
  description = "Enable baseline alerts (CPU high, sessions near cap)."
  type        = bool
  default     = true
}

variable "create_action_group" {
  description = "Create a new Action Group; if false, provide action_group_id."
  type        = bool
  default     = true
}

variable "alert_emails" {
  description = "Email addresses for notifications (used if create_action_group = true)."
  type        = list(string)
  default     = []
}

variable "action_group_id" {
  description = "Existing Action Group ID (used if create_action_group = false)."
  type        = string
  default     = null
}

variable "cpu_high_threshold" {
  description = "CPU % threshold for the metric alert."
  type        = number
  default     = 85
}

variable "sessions_near_cap_threshold" {
  description = "Average active sessions per host threshold for the KQL alert (e.g., 8 if cap=10)."
  type        = number
  default     = 8
}
