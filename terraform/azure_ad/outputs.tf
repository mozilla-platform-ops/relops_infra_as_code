data "azuread_client_config" "current" {
}

output "account_id" {
  value = data.azuread_client_config.current.client_id
}

data "azuread_domains" "aad_domains" {}

output "domains" {
  value = data.azuread_domains.aad_domains.domains
}

output "azure_janitor" {
  description = "Azure cleanup workflow client ID and RBAC principal ID."
  value = {
    client_id    = azuread_application.clauditor["janitor"].client_id
    principal_id = azuread_service_principal.clauditor["janitor"].object_id
  }
}
