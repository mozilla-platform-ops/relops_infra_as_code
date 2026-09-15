# FooFrix identities. Subscription roles are in azure_foofrix. RELOPS-2548.
# Create the client secret outside Terraform and store it in 1Password.
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

resource "azuread_group" "platform_performance" {
  display_name     = "Platform Performance"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps - Platform Performance team"
}

resource "azuread_group_member" "platform_performance" {
  for_each = {
    dpalmeiro = "2e8c6f6d-9dae-42b3-a193-5ea7c4b09cb5"
    jlink     = "d76c0d0a-537a-42a3-9ac7-0d96caa8e054"
  }
  group_object_id  = azuread_group.platform_performance.object_id
  member_object_id = each.value
}

resource "azuread_application" "foofrix_image_build" {
  display_name = "sp-foofrix-image-build"
  owners       = data.azuread_group.relops.members
  notes        = "FooFrix Windows image builds from worker-images. RELOPS-2570."
}

resource "azuread_service_principal" "foofrix_image_build" {
  client_id = azuread_application.foofrix_image_build.client_id
  owners    = data.azuread_group.relops.members
  tags      = concat(["name:sp-foofrix-image-build"], local.sp_tags)
}

resource "azuread_application_federated_identity_credential" "foofrix_image_build" {
  application_id = azuread_application.foofrix_image_build.id
  display_name   = "github-worker-images-foofrix"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:mozilla-platform-ops/worker-images:environment:foofrix-image-build"
}
