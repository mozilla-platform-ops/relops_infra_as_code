/*
=================================================
PROVIDERS
=================================================
*/
provider "azurerm" {
  environment     = var.environment
  subscription_id = var.azure_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

