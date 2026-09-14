# FooFrix identities. Subscription roles are in azure_foofrix. RELOPS-2548.
# Add GCP federation when the service account unique ID is known.
resource "azuread_application" "foofrix" {
  display_name = "sp-foofrix-azure-devtest"
  owners       = data.azuread_group.relops.members
  notes        = "GCP provisioning identity for the FooFrix Azure DevTest Subscription. RELOPS-2548."
}

resource "azuread_service_principal" "foofrix" {
  client_id = azuread_application.foofrix.client_id
  owners    = data.azuread_group.relops.members
  tags      = concat(["name:sp-foofrix-azure-devtest"], local.sp_tags)
}
