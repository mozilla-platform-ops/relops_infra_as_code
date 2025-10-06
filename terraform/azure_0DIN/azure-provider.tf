# Configure the Azure Provider
provider "azurerm" {
  features {}

  # 0DIN dev/test Subscription
  subscription_id = "e1cb04e4-3788-471a-881f-385e66ad80ab"
  tenant_id       = "c0dc8bb0-b616-427e-8217-9513964a145b"
}
