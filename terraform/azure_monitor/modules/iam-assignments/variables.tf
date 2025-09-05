variable "app_group_id" {
  type = string
  # ID of the AVD Application Group where users/groups will be granted access
}

variable "principal_ids" {
  description = "List of Entra ID user or group object IDs to assign Desktop Virtualization User role"
  type        = list(string)
  default     = []
}