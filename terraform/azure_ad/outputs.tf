data "azuread_client_config" "current" {
}

output "account_id" {
  value = data.azuread_client_config.current.client_id
}

data "azuread_domains" "aad_domains" {}

output "domains" {
  value = data.azuread_domains.aad_domains.domains
}

