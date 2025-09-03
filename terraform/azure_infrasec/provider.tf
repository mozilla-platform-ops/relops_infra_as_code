# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = local.infra_sec_subscription
  tenant_id       = local.mozilla_tenant_id
}

# Configure the Azure AD Provider
provider "azuread" {
  tenant_id = local.mozilla_tenant_id
}
