# Configure the Azure Provider
provider "azurerm" {
  features {}

  # TCEng dev/test Subscription
  subscription_id = "8a205152-b25a-417f-a676-80465535a6c9"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
