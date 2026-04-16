# "Splunk Logging" app registration — Mozilla-owned, created manually in 2023.
# Brought under terraform to create its missing service principal; required by
# Microsoft's March 2026 retirement of service-principal-less authentication.
resource "azuread_application" "splunk_logging" {
  display_name     = "Splunk Logging"
  sign_in_audience = "AzureADMyOrg"

  owners = data.azuread_group.relops.members

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "b0afded3-3588-46d8-8b3d-9842eff778da" # AuditLog.Read.All (application)
      type = "Role"
    }
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All (application)
      type = "Role"
    }
    resource_access {
      id   = "38d9df27-64da-44fd-b7c5-a6fbac20248f" # Policy.Read.All (application)
      type = "Role"
    }
    resource_access {
      id   = "381f742f-e1f8-4309-b4ab-e3d91ae4c5c1" # Directory.Read.All (application)
      type = "Role"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # AuditLog.Read.All (delegated)
      type = "Scope"
    }
    resource_access {
      id   = "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20" # Directory.AccessAsUser.All (delegated)
      type = "Scope"
    }
    resource_access {
      id   = "57b030f1-8c35-469c-b0d9-e4a077debe70" # User.Read.All (delegated)
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "splunk_logging" {
  client_id    = azuread_application.splunk_logging.client_id
  use_existing = true
}

# Remove after first successful apply; retained as a record of the import.
import {
  to = azuread_application.splunk_logging
  id = "/applications/443480b6-0203-45b5-a128-c61633a68e05"
}
