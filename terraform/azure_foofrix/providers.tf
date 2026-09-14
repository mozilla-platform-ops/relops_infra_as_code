terraform {
  required_version = ">= 1.10"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
}

# Use an existing subscription to create the new subscription first.
provider "azurerm" {
  alias = "billing"
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  tenant_id                       = local.tenant_id
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = azurerm_subscription.foofrix.subscription_id
  tenant_id                       = local.tenant_id
}

provider "azuread" {
  tenant_id = local.tenant_id
}
