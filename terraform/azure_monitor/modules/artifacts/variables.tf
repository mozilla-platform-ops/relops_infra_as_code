variable "name" {
  description = "Short name/prefix for storage resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for storage resources."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

variable "container_name" {
  description = "Blob container name to hold bootstrap scripts."
  type        = string
  default     = "bootstrap"
}

variable "script_local_path" {
  description = "Local path to avd-session-init.ps1."
  type        = string
}

variable "script_blob_name" {
  description = "Blob name to use for the uploaded script."
  type        = string
  default     = "avd-session-init.ps1"
}

variable "sas_expiry_hours" {
  description = "How long the SAS token should be valid (hours)."
  type        = number
  default     = 24
}
