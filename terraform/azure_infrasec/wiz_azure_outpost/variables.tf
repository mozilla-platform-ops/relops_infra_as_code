/*
=================================================
REQUIRED VARS
=================================================
*/

# Azure Tenant ID
variable "azure_tenant_id" {
  type        = string
  description = "(Required) The Azure Tenant ID"
  validation {
    condition     = can(regex("^(\\{{0,1}([0-9a-fA-F]){4,8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12,13}\\}{0,1})$", var.azure_tenant_id))
    error_message = "Invalid Azure Tenant ID. Please check your input again."
  }
}

# The Wiz Orchestrator Resource Group Region/Location
variable "wiz_global_orchestrator_rg_region" {
  type        = string
  description = "(Required) The Azure region for the Wiz resource group"
}

# Subscription ID
variable "azure_subscription_id" {
  type        = string
  description = "(Required) The Azure subscription id where you want to deploy the Wiz outpost"
  validation {
    condition     = can(regex("^(\\{{0,1}([0-9a-fA-F]){4,8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12,13}\\}{0,1})$", var.azure_subscription_id))
    error_message = "Invalid Azure Subscription ID. Please check your input again."
  }
}

# The Wiz keyvault name
variable "wiz_application_keyvault_name" {
  type        = string
  description = "(Required) The name of the vault used by Wiz outpost"
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{3,24}[A-Za-z0-9]$", var.wiz_application_keyvault_name))
    error_message = "Invalid Keyvault Name. Keyvault name must contain only alphanumerics and hyphens, be between 3-24 characters, start with letter, End with letter or digit, and can't contain consecutive hyphens."
  }
}

# The Wiz Orchestrator Resource Group name
variable "wiz_global_orchestrator_rg_name" {
  type        = string
  description = "(Optional) The name for the Wiz Resource group name - Default: wiz-orchestrator-global-rg"
  validation {
    condition     = can(regex("^[-\\w\\._\\(\\)]{1,90}$", var.wiz_global_orchestrator_rg_name))
    error_message = "Invalid Azure Resouce Group Name. Resource group name must include no more than 90 alphanumeric, underscore, parentheses, hyphen, period (except at end), and Unicode characters that match the allowed characters."
  }
  default = "wiz-orchestrator-global-rg"
}

# When set we will use Wiz Managed Entraprise App instead of creating a new one 
variable "wiz_da_orchestrator_wiz_managed_app_id" {
  type        = string
  description = "Client ID of your Wiz's tenant managed Entra ID application."
  default     = "00000000-0000-0000-0000-000000000000"
  validation {
    condition     = can(regex("^(\\{{0,1}([0-9a-fA-F]){4,8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12,13}\\}{0,1})$", var.wiz_da_orchestrator_wiz_managed_app_id))
    error_message = "Invalid Wiz Managed App ID. Please check your input again."
  }
}

# When using Self Managed network
variable "self-managed-network" {
  type        = bool
  default     = false
  description = "Use auto/manual network. False (default): regular Outpost. True: Self-managed network Outpost."
}


/*
=================================================
OPTIONAL VARS
=================================================
*/

variable "environment" {
  type        = string
  description = "(Optional) The terraform environment to deploy into - Default: public. Options: public, usgovernment, german, china"
  default     = "public"
}
variable "azure_wait_timer" {
  type        = string
  description = "(Optional) Wait timer for Azure dataplane propagation - Default: 600"
  default     = "600s"
}
variable "enable_data_scanning" {
  type        = bool
  description = "(Optional) Enable data scanning - Default: false"
}

variable "multi_tenancy_enabled" {
  type        = bool
  description = "(Optional) Enable the Wiz Disk Analyzer - Scanner app for multi-tenant usage - Default: false"
  default     = false
}

# Set the default expiration date for custom sp/app keys to 10 years from current date
variable "key_expire_end_date_relative" {
  type        = string
  description = "(Optional) Hours for password expiration for Wiz apps - Default: 87600h = 24h * 365 days * 10 years"
  default     = "87600h"
}

/*
WORKER APP VARS
*/

# Worker app name
variable "wiz_da_worker_app_name" {
  type        = string
  description = "(Optional) Name of the Wiz Disk Analyzer - Worker app - Default: Wiz Disk Analyzer - Worker"
  default     = "Wiz Disk Analyzer - Worker"
}

# Worker app secret
variable "wiz_da_worker_app_secret" {
  type        = string
  description = "(Optional) A secret for the Wiz Disk Analyzer - Worker app - Default: wiz_auto_create_pass - create a secret automatically"
  default     = "wiz_auto_create_secret"
}

/*
  WORKER Managed Identity VARS
*/

# Use worker managed identity instead of Worker app
variable "use_worker_managed_identity" {
  type        = bool
  description = "(Optional) create a worker managed identity instead of worker app"
  default     = false
}

# Worker managed identity name
variable "wiz_da_worker_identity_name" {
  type        = string
  description = "(Optional) worker managed identity name - Default: WizWorkerIdentity"
  default     = "WizWorkerIdentity"
}

# Control plane managed identity name
variable "wiz_da_control_plane_identity_name" {
  type        = string
  description = "(Optional) control plane identity name - Default: WizControlPlaneIdentity"
  default     = "WizControlPlaneIdentity"
}

/*
ORCHESTRATOR APP VARS
*/


# Orchestrator app name
variable "wiz_da_orchestrator_app_name" {
  type        = string
  description = "(Optional) Name of the Wiz Disk Analyzer - Orchestrator app - Default: Wiz Disk Analyzer - Orchestrator"
  default     = "Wiz Disk Analyzer - Orchestrator"
}

/*
SCANNER APP VARS
*/

# Worker app name
variable "wiz_da_scanner_app_name" {
  type        = string
  description = "(Optional) Name of the Wiz Disk Analyzer - Scanner app - Default: Wiz Disk Analyzer - Scanner"
  default     = "Wiz Disk Analyzer - Scanner"
}

# Scanner app secret
variable "wiz_da_scanner_app_secret" {
  type        = string
  description = "(Optional) A secret for the Wiz Disk Analyzer - Scanner app - Default: wiz_auto_create_pass - create a secret automatically"
  default     = "wiz_auto_create_secret"
}

# Scanner app key vault certificate pem file path
variable "scanner_app_key_vault_certificate_pem_file_path" {
  type        = string
  description = "(Optional) The path to the pem file for the Scanner app key vault certificate"
  default     = null
}

/*
ROLE NAMES
*/

# Data scanning role name
variable "wiz_custom_data_scanning_role_name" {
  type        = string
  default     = "WizOrchestratorDataScanningRole"
  description = "(Optional) Name of the custom Wiz role - Default: WizOrchestratorDataScanningRole"
}

# Orchestrator role name
variable "wiz_custom_orchestrator_role_name" {
  type        = string
  default     = "WizOrchestratorRole"
  description = "(Optional) Name of the custom Wiz role - Default: WizOrchestratorRole"
}

# Data scanning copy custom role name
variable "wiz_custom_data_scanning_copy_role_name" {
  type        = string
  default     = "WizDataCopyCustomRole"
  description = "(Optional) Name of the custom Wiz role - Default: WizDataCopyCustomRole"
}

# Disk copy custom role name
variable "wiz_custom_disk_copy_role_name" {
  type        = string
  default     = "WizDiskCopyCustomRole"
  description = "(Optional) Name of the custom Wiz role - Default: WizDiskCopyCustomRole"
}

# Disk manager custom role name
variable "wiz_custom_orch_disk_manager_worker_role_name" {
  type        = string
  default     = "WizOrchestratorDiskmanagerWorkerRole"
  description = "(Optional) Name of the custom Wiz role - Default: WizOrchestratorDiskmanagerWorkerRole"
}
