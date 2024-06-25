# Configure the Azure Provider
provider "azurerm" {
  features {}

  # FXCI Azure dev/test Subscription
  subscription_id = "0a420ff9-bc77-4475-befc-a05071fc92ec"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

data "azurerm_subscription" "currentSubscription" {}