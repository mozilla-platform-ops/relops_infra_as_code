# Azure identity, cost access, and worker inventory for the try-push inspector.
# Configure an application credential separately for unattended authentication.
resource "azuread_application" "l1_push_cost_inspector" {
  display_name = "l1-push-cost-inspector"
  owners       = data.azuread_group.relops.members
  notes        = "Read-only Azure FXCI try-push cost inspection."
}

resource "azuread_service_principal" "l1_push_cost_inspector" {
  client_id = azuread_application.l1_push_cost_inspector.client_id
  owners    = data.azuread_group.relops.members
  tags      = concat(["name:l1-push-cost-inspector"], local.sp_tags)
}

resource "azurerm_role_assignment" "l1_push_cost_inspector_cost_reader" {
  role_definition_name = "Cost Management Reader"
  principal_id         = azuread_service_principal.l1_push_cost_inspector.object_id
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}"
}

resource "azurerm_role_assignment" "l1_push_cost_inspector_worker_reader" {
  for_each = toset([
    "rg-tc-gecko-1-b-win2022",
    "rg-tc-gecko-t-win11-64-25h2",
    "rg-tc-gecko-t-win11-64-25h2-gpu",
    "rg-tc-gecko-t-win11-64-25h2-large",
    "rg-tc-gecko-t-win11-64-25h2-source",
  ])

  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.l1_push_cost_inspector.object_id
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}/resourceGroups/${each.value}"
}

output "l1_push_cost_inspector_client_id" {
  description = "Application client ID for the try-push inspector's Azure login."
  value       = azuread_application.l1_push_cost_inspector.client_id
}

output "l1_push_cost_inspector_object_id" {
  description = "Service principal object ID for the try-push inspector."
  value       = azuread_service_principal.l1_push_cost_inspector.object_id
}
