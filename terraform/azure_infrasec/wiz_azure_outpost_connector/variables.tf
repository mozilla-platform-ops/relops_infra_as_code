variable "azure_tenant_id" {
  type        = string
  description = "The Azure tenant ID for the deployment"
  default     = ""
}

# tflint-ignore: terraform_unused_declarations
variable "azure_environment" {
  type        = string
  default     = "public"
  description = <<EOF
    DEPRECATED: This variable is deprecated and will be removed in a future release. Please set this in your terraform provider block instead.
    
    The Cloud Environment which should be used, possible values are: public, usgovernment, german, and china.
    Defaults to public. 
  EOF
}

variable "azure_management_group_id" {
  type        = string
  default     = ""
  description = <<EOF
    If set, will add role assignments for the wiz application to the management group.
    Takes precedence over subscription_id.
  EOF
}

variable "azure_subscription_id" {
  type        = string
  default     = ""
  description = <<EOF
    If set, will add role assignments for the wiz application to the subscription.
    If management_group_id is set, it takes precedence.
  EOF
}

variable "wiz_custom_role_name" {
  type        = string
  default     = "WizCustomRole"
  description = "(Optional) The name of the Azure custom role to create. Defaults to WizCustomRole."
}

variable "enable_entra_id_scanning" {
  type        = bool
  default     = false
  description = "If set, adds permissions for Entra ID scanning to the Azure Service Principal. Default is false."
}

variable "wiz_app_id" {
  type        = string
  description = "Client ID of your Wiz's tenant managed Entra ID application."
}

variable "wiz_da_scanner_app_id" {
  type        = string
  description = "Client ID of your Wiz's tenant managed DA Scanner application."
  default     = ""
}

variable "wiz_disk_analyzer_role_name" {
  type        = string
  default     = "WizDiskAnalyzerRole"
  description = "(Optional) The name of the Wiz custom disk scanning role"
}

variable "wiz_data_scanning_role_name" {
  type        = string
  default     = "WizDataScanningRole"
  description = "(Optional) The name of the Wiz custom data scanning role"
}

variable "wiz_serverless_scanning_role_name" {
  type        = string
  default     = "WizServerlessScanningRole"
  description = "(Optional) The name of the Wiz custom serverless scanning role"
}

variable "enable_data_scanning" {
  type        = bool
  default     = false
  description = "If set, adds data scanning required permissions to the Wiz custom role. Default is false."
}

variable "enable_serverless_scanning" {
  type        = bool
  default     = false
  description = "If set, adds serverless scanning required permissions to the Wiz custom role. Default is false."
}

variable "enable_openai_scanning" {
  type        = bool
  default     = false
  description = "If set, adds the required role for OpenAI scanning by Wiz. Default is false."
}

variable "azure_wait_timer" {
  type        = string
  description = "(Optional) Wait timer for Azure dataplane propagation - Default: 600"
  default     = "600s"
}

variable "use_existing_service_principal" {
  type        = bool
  default     = false
  description = "If set to true, use an existing service principal instead of creating a new one."
}

variable "wiz_app_object_id" {
  type        = string
  default     = ""
  description = <<EOF
    (Optional) The object ID of an existing service principal to use directly.
    If provided, this will bypass the lookup by client_id/app_id and use this object_id directly.
    This is useful when the service principal lookup by client_id fails in the environment.
  EOF
}
