data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

data "azuread_group" "infra_sec_users" {
  display_name = "Infrastructure Security Team"
}