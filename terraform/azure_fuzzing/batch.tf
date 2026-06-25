locals {
  batch_location = "South Central US"
}

data "azurerm_resource_group" "clauditor" {
  name = "clauditor"

  depends_on = [azurerm_subscription.fuzzing]
}

resource "azuread_service_principal" "microsoft_azure_batch" {
  client_id    = "ddbf3205-c6bd-46ae-8127-60eb93363864"
  use_existing = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "batch_service_orchestration" {
  scope                            = "/subscriptions/${azurerm_subscription.fuzzing.subscription_id}"
  role_definition_name             = "Azure Batch Service Orchestration Role"
  principal_id                     = azuread_service_principal.microsoft_azure_batch.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_resource_provider_registration.this["Microsoft.Batch"],
  ]
}

resource "azurerm_key_vault" "batch_southcentralus" {
  name                            = "kv-clauditor-batch"
  location                        = local.batch_location
  resource_group_name             = data.azurerm_resource_group.clauditor.name
  tenant_id                       = local.tenant_id
  sku_name                        = "standard"
  rbac_authorization_enabled      = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tags                            = local.common_tags

  depends_on = [
    azurerm_resource_provider_registration.this["Microsoft.KeyVault"],
  ]
}

resource "azurerm_role_assignment" "batch_key_vault_secrets_officer" {
  scope                            = azurerm_key_vault.batch_southcentralus.id
  role_definition_name             = "Key Vault Secrets Officer"
  principal_id                     = azuread_service_principal.microsoft_azure_batch.object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "relops_key_vault_administrator" {
  scope                = azurerm_key_vault.batch_southcentralus.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_group.relops.object_id
  principal_type       = "Group"
}

resource "azurerm_batch_account" "fuzzing_southcentralus" {
  name                         = "clauditorbatch"
  resource_group_name          = data.azurerm_resource_group.clauditor.name
  location                     = local.batch_location
  pool_allocation_mode         = "UserSubscription"
  allowed_authentication_modes = ["AAD"]
  tags                         = local.common_tags

  key_vault_reference {
    id  = azurerm_key_vault.batch_southcentralus.id
    url = azurerm_key_vault.batch_southcentralus.vault_uri
  }

  depends_on = [
    azurerm_role_assignment.batch_service_orchestration,
    azurerm_role_assignment.batch_key_vault_secrets_officer,
  ]
}
