# The try-push inspector exchanges its existing GCP service-account ID token for
# Azure access, keeping authentication independent of a personal Azure login.
resource "azuread_application" "l1_push_cost_inspector" {
  display_name = "l1-push-cost-inspector"
  owners       = data.azuread_group.relops.members
  notes        = "Read-only FXCI try-push cost inspection using GCP service account federation."
}

resource "azuread_service_principal" "l1_push_cost_inspector" {
  client_id = azuread_application.l1_push_cost_inspector.client_id
  owners    = data.azuread_group.relops.members
  tags      = concat(["name:l1-push-cost-inspector"], local.sp_tags)
}

resource "azuread_application_federated_identity_credential" "l1_push_cost_inspector_azure" {
  application_id = azuread_application.l1_push_cost_inspector.id
  display_name   = "l1-push-cost-inspector-azure"
  description    = "l1-push-cost-inspector@fxci-production-level1-workers.iam.gserviceaccount.com"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://accounts.google.com"
  subject        = "108483818865389271174"
}

resource "azurerm_role_assignment" "l1_push_cost_inspector_cost_reader" {
  role_definition_name = "Cost Management Reader"
  principal_id         = azuread_service_principal.l1_push_cost_inspector.object_id
  scope                = "/subscriptions/${var.fxci_devtest_subscription_id}"
}

output "l1_push_cost_inspector_client_id" {
  description = "Application client ID for the try-push inspector's federated Azure login."
  value       = azuread_application.l1_push_cost_inspector.client_id
}

output "l1_push_cost_inspector_object_id" {
  description = "Service principal object ID for the try-push inspector."
  value       = azuread_service_principal.l1_push_cost_inspector.object_id
}
