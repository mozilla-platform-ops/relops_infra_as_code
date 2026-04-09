module "arm_subscription_throttling_dashboard" {
  source = "../azure_modules/arm_subscription_throttling_dashboard"

  resource_group_id         = azurerm_resource_group.rg-central-us-trusted-runbooks.id
  location                  = azurerm_resource_group.rg-central-us-trusted-runbooks.location
  subscription_id           = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
  subscription_display_name = "Trusted FXCI Azure DevTest Subscription"
  dashboard_name            = "arm-throttle-tfxci"
  dashboard_display_name    = "Trusted FXCI ARM Throttling"
  tags                      = local.common_tags
}
