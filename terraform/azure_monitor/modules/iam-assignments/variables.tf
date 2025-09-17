variable "app_group_id" {
  description = "Resource ID of the AVD Desktop Application Group (scope for role assignments)."
  type        = string
}

variable "principal_ids" {
  description = "Azure AD object IDs (users or groups) to grant role assignments."
  type        = list(string)
  default     = []
}

variable "role_definition_name" {
  description = "Built-in role name to assign at the DAG scope."
  type        = string
  default     = "Desktop Virtualization User"
}
