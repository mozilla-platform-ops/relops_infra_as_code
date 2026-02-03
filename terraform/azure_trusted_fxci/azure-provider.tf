# Configure the Azure Provider
provider "azurerm" {
  features {}

  # FXCI Trusted Azure dev/test Subscription
  subscription_id = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

provider "azapi" {
  subscription_id = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
