# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = local.infra_sec_subscription
  tenant_id       = local.mozilla_tenant_id
}
