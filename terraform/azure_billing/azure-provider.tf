# Provider configuration for billing-scoped resources
# Billing APIs are tenant-scoped; subscription_id is only needed for authentication
provider "azurerm" {
  features {}

  # Using FXCI subscription for authentication
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

provider "azapi" {
  subscription_id = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
