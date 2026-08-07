# Mozilla-owned identity for the Firefox WNS work in Bug 1803416.
# Add a client credential only after the sender and secret store are defined.

data "azuread_user" "aborondo" {
  user_principal_name = "aborondo@mozilla.com"
}

locals {
  firefox_wns_owners = concat(
    data.azuread_group.relops.members,
    [data.azuread_user.aborondo.object_id],
  )
}

resource "azuread_application" "firefox_wns" {
  display_name     = "Firefox WNS"
  description      = "Mozilla-owned identity for Firefox Windows App SDK push notification work (RELOPS-2495, Bug 1803416)."
  sign_in_audience = "AzureADMultipleOrgs"
  owners           = local.firefox_wns_owners
}

resource "azuread_service_principal" "firefox_wns" {
  client_id = azuread_application.firefox_wns.client_id
  owners    = local.firefox_wns_owners
  tags      = concat(["name:firefox-wns"], local.sp_tags)
}

output "firefox_wns_client_id" {
  description = "Application client ID used for WNS activation and access-token requests."
  value       = azuread_application.firefox_wns.client_id
}

output "firefox_wns_service_principal_object_id" {
  description = "Service principal object ID used as the Windows App SDK WNS remote identifier."
  value       = azuread_service_principal.firefox_wns.object_id
}
