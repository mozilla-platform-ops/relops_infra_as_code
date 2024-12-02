locals {
  tags = {
    terraform        = "true"
    project_name     = "hgbundle"
    production_state = var.tag_production_state
    owner_email      = "relops@mozilla.com"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  regions = toset([
    "canadacentral",
    "centralindia",
    "centralus",
    "eastus",
    "eastus2",
    "northcentralus",
    "northeurope",
    "southindia",
    "westus",
    "westus2",
    "westus3",
  ])
}

## Create storage accounts for each region
data "azurerm_resource_group" "hgbundle" {
  for_each = local.regions
  name     = "rg-${each.value}-hgbundle"
}

resource "azuread_application" "hgbundle" {
  display_name = "moz_hgbundle"
  owners       = [data.azuread_user.jmoss.id]
  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access moz_hgbundle on behalf of the signed-in user."
      admin_consent_display_name = "Access moz_hgbundle"
      enabled                    = true
      id                         = "9b2c56f6-3371-49f3-8023-d11c3472ef2e"
      type                       = "User"
      user_consent_description   = "Allow the application to access moz_hgbundle on your behalf."
      user_consent_display_name  = "Access moz_hgbundle"
      value                      = "user_impersonation"
    }
  }
}

resource "azuread_service_principal" "hgbundle" {
  client_id = azuread_application.hgbundle.client_id
}

resource "azurerm_role_assignment" "hgbundle" {
  for_each             = local.regions
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.hgbundle.object_id
  scope                = data.azurerm_resource_group.hgbundle[each.key].id
}