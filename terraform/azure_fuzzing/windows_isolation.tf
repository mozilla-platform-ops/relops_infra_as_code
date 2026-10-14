# Shared infrastructure for identity-less Windows agents and single-use Batch harnesses.
locals {
  agent_subnet_prefix   = "10.1.3.0/24"
  harness_subnet_prefix = "10.1.0.0/24"
}

data "azuread_service_principal" "azure_janitor" {
  display_name = "sp-fuzzing-azure-janitor"
}

data "azurerm_user_assigned_identity" "run" {
  name                = "clauditor-run-identity"
  resource_group_name = data.azurerm_resource_group.clauditor.name
}

data "azurerm_virtual_network" "run" {
  name                = "clauditor-run-vnet"
  resource_group_name = data.azurerm_resource_group.clauditor.name
}

data "azurerm_shared_image_gallery" "images" {
  name                = "clauditor_gallery"
  resource_group_name = data.azurerm_resource_group.clauditor.name
}

resource "azurerm_resource_group" "windows_agents" {
  name     = "fuzzing-windows-agents"
  location = local.batch_location
  tags     = local.common_tags
}

resource "azurerm_network_security_group" "windows_agents" {
  name                = "fuzzing-agent-subnet-nsg"
  location            = data.azurerm_virtual_network.run.location
  resource_group_name = data.azurerm_resource_group.clauditor.name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "agent_harness" {
  name                        = "harness-services"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["445", "3128"]
  source_address_prefix       = "*"
  destination_address_prefix  = local.harness_subnet_prefix
  resource_group_name         = data.azurerm_resource_group.clauditor.name
  network_security_group_name = azurerm_network_security_group.windows_agents.name
}

resource "azurerm_network_security_rule" "agent_deny" {
  for_each = {
    deny-platform-dns   = { priority = 150, direction = "Outbound", destination = "AzurePlatformDNS" }
    deny-imds           = { priority = 151, direction = "Outbound", destination = "AzurePlatformIMDS" }
    deny-other-outbound = { priority = 200, direction = "Outbound", destination = "*" }
    deny-inbound        = { priority = 100, direction = "Inbound", destination = "*" }
  }
  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = each.value.destination
  resource_group_name         = data.azurerm_resource_group.clauditor.name
  network_security_group_name = azurerm_network_security_group.windows_agents.name
}

resource "azurerm_route_table" "windows_agents" {
  name                          = "fuzzing-agent-subnet-routes"
  location                      = data.azurerm_virtual_network.run.location
  resource_group_name           = data.azurerm_resource_group.clauditor.name
  bgp_route_propagation_enabled = false
  tags                          = local.common_tags
}

resource "azurerm_route" "agent_no_internet" {
  name                = "no-internet"
  resource_group_name = data.azurerm_resource_group.clauditor.name
  route_table_name    = azurerm_route_table.windows_agents.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "None"
}

resource "azurerm_subnet" "windows_agents" {
  name                            = "fuzzing-agent-subnet"
  resource_group_name             = data.azurerm_resource_group.clauditor.name
  virtual_network_name            = data.azurerm_virtual_network.run.name
  address_prefixes                = [local.agent_subnet_prefix]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet_network_security_group_association" "windows_agents" {
  subnet_id                 = azurerm_subnet.windows_agents.id
  network_security_group_id = azurerm_network_security_group.windows_agents.id
  depends_on = [
    azurerm_network_security_rule.agent_harness,
    azurerm_network_security_rule.agent_deny,
  ]
}

resource "azurerm_subnet_route_table_association" "windows_agents" {
  subnet_id      = azurerm_subnet.windows_agents.id
  route_table_id = azurerm_route_table.windows_agents.id
  depends_on     = [azurerm_route.agent_no_internet]
}

# This grant already exists; import it without replacing its assignment ID.
resource "azurerm_role_assignment" "agent_gallery" {
  name                 = "1407816a-f842-43ce-8532-307d15985beb"
  scope                = data.azurerm_shared_image_gallery.images.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.run.principal_id
  principal_type       = "ServicePrincipal"
  lifecycle {
    prevent_destroy = true
  }
}

import {
  to = azurerm_role_assignment.agent_gallery
  id = "/subscriptions/d6e6a496-6005-4e31-b2f5-209440c2cf52/resourceGroups/clauditor/providers/Microsoft.Compute/galleries/clauditor_gallery/providers/Microsoft.Authorization/roleAssignments/1407816a-f842-43ce-8532-307d15985beb"
}

output "windows_isolation" {
  description = "Runtime and GitHub Azure environment settings for isolated Windows runs."
  value = {
    AZURE_AGENT_RESOURCE_GROUP   = azurerm_resource_group.windows_agents.name
    AZURE_AGENT_SUBNET_ID        = azurerm_subnet.windows_agents.id
    AZURE_RUN_IDENTITY_ID        = data.azurerm_user_assigned_identity.run.id
    AZURE_RUN_IDENTITY_CLIENT_ID = data.azurerm_user_assigned_identity.run.client_id
    AZURE_JANITOR_CLIENT_ID      = data.azuread_service_principal.azure_janitor.client_id
    AZURE_BATCH_ACCOUNT          = azurerm_batch_account.fuzzing_southcentralus.name
    AZURE_LOCATION               = "southcentralus"
    AZURE_POOL_ID                = "clauditor-win"
    AZURE_SUBSCRIPTION_ID        = local.fuzzing_subscription_id
    AZURE_TENANT_ID              = local.tenant_id
  }
}
