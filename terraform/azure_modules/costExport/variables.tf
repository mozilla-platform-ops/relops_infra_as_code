variable "columns" {
  description = "List of columns to include in the export"
  type        = list(string)
  default     = []
}

variable "compression_mode" {
  description = "Compression mode: None, GZip"
  type        = string
  default     = "None"
}

variable "container_name" {
  description = "Storage container name for cost exports"
  type        = string
  default     = "cost-management"
}

variable "cost_type" {
  description = "Type of cost export: ActualCost, AmortizedCost, or Usage"
  type        = string
  default     = "ActualCost"
}

variable "data_overwrite_behavior" {
  description = "Data overwrite behavior: CreateNewReport, OverwritePreviousReport"
  type        = string
  default     = "CreateNewReport"
}

variable "data_version" {
  description = "Data version for the export configuration"
  type        = string
  default     = "2023-05-01"
}

variable "export_description" {
  description = "Description of the cost export"
  type        = string
  default     = "Azure Cost Export"
}

variable "export_name" {
  description = "Name of the cost export"
  type        = string
}

variable "format" {
  description = "Export format: Csv or Parquet"
  type        = string
  default     = "Csv"
}

variable "granularity" {
  description = "Granularity of the export data: Daily, Monthly. Set to null to omit (required for some reservation export types)."
  type        = string
  default     = "Daily"
}

variable "parent_id" {
  description = "Parent ID for the cost export (billing account, subscription, resource group, etc.)"
  type        = string
}

variable "partition_data" {
  description = "Whether to partition the exported data"
  type        = bool
  default     = true
}

variable "recurrence" {
  description = "Recurrence pattern: Daily, Weekly, Monthly, or Annually"
  type        = string
  default     = "Daily"
}

variable "recurrence_period_from" {
  description = "Start date for recurrence period (ISO 8601 format)"
  type        = string
  default     = "2024-10-01T00:00:00Z"
}

variable "recurrence_period_to" {
  description = "End date for recurrence period (ISO 8601 format)"
  type        = string
  default     = "2050-02-01T00:00:00Z"
}

variable "root_folder_path" {
  description = "Root folder path within the container"
  type        = string
}

variable "status" {
  description = "Status of the export schedule: Active or Inactive"
  type        = string
  default     = "Active"
}

variable "storage_account_id" {
  description = "Resource ID of the storage account for export destination"
  type        = string
}

variable "timeframe" {
  description = "Timeframe for the export: MonthToDate, WeekToDate, Custom, etc."
  type        = string
  default     = "MonthToDate"
}
