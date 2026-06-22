provider "azurerm" {
  features {}

  # Existing subscription used only as the provider authentication context.
  subscription_id = local.provider_auth_subscription_id
  tenant_id       = local.tenant_id
}

provider "azuread" {
  tenant_id = local.tenant_id
}
