variable "app_group_id" {
  description = "The ID of the AVD Application Group where role assignments should be applied"
  type        = string
}

variable "principal_ids" {
  description = "List of Entra ID object IDs (users or groups) to assign the Desktop Virtualization User role"
  type        = list(string)
  default     = []
}
