variable "dashboard_display_name" {
  description = "Portal display name for the dashboard."
  type        = string
}

variable "dashboard_name" {
  description = "Azure resource name for the dashboard."
  type        = string
}

variable "location" {
  description = "Azure region where the dashboard resource will live."
  type        = string
}

variable "metric_timespan" {
  description = "Default timespan for dashboard metrics."
  type        = string
  default     = "P7D"
}

variable "resource_group_id" {
  description = "Resource group resource ID used as the dashboard parent."
  type        = string
}

variable "subscription_display_name" {
  description = "Human-readable subscription name shown in dashboard markdown."
  type        = string
}

variable "subscription_id" {
  description = "Subscription GUID for the monitored Azure subscription."
  type        = string
}

variable "tags" {
  description = "Tags applied to the dashboard resource."
  type        = map(string)
}
