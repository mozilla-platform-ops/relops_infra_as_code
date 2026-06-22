provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
  subscription_id                 = local.fuzzing_subscription_id
  tenant_id                       = local.tenant_id
}

provider "azuread" {
  tenant_id = local.tenant_id
}
