# Configure the Azure Provider
provider "azurerm" {
  features {}

  # TCEng dev/test Subscription
  subscription_id = "8a205152-b25a-417f-a676-80465535a6c9"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
provider "azapi" {
  subscription_id = "0a420ff9-bc77-4475-befc-a05071fc92ec"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

data "azurerm_subscription" "currentSubscription" {}
