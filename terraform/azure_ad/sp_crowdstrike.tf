# Entra ID application used by CrowdStrike Falcon NGSIEM to consume events
# from the mozcrowdstrikeeventhub Event Hub Namespace (terraform/azure_infrasec).
#
# The client secret is managed in the Azure portal, not in Terraform.
# After the application is created by this config, go to
# Entra ID > App registrations > sp-infosec-crowdstrike-eventhub >
# Certificates & secrets, create a client secret, and hand it to SecOps along
# with the client ID and tenant ID.

resource "azuread_application" "crowdstrikeeventhub" {
  display_name = "sp-infosec-crowdstrike-eventhub"
  owners       = [data.azuread_user.jmoss.object_id]

  web {
    redirect_uris = []

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "crowdstrikeeventhub" {
  client_id                    = azuread_application.crowdstrikeeventhub.client_id
  app_role_assignment_required = false
}

output "crowdstrike_eventhub_client_id" {
  description = "Application (client) ID for the Falcon NGSIEM data connector."
  value       = azuread_application.crowdstrikeeventhub.client_id
}

output "crowdstrike_eventhub_tenant_id" {
  description = "Directory (tenant) ID for the Falcon NGSIEM data connector."
  value       = data.azuread_client_config.current.tenant_id
}
