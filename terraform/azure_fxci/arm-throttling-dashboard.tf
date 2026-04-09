module "arm_subscription_throttling_dashboard" {
  source = "../azure_modules/arm_subscription_throttling_dashboard"

  resource_group_id         = azurerm_resource_group.rg-central-us-runbooks.id
  location                  = azurerm_resource_group.rg-central-us-runbooks.location
  subscription_id           = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
  subscription_display_name = "FXCI Azure DevTest Subscription"
  dashboard_name            = "arm-throttle-fxci"
  dashboard_display_name    = "FXCI ARM Throttling"
  tags                      = local.common_tags
}
