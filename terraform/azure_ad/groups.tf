resource "azuread_group" "zero_din" {
  display_name     = "0DIN"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — 0DIN project members"
}

data "azuread_user" "zero_din_members" {
  for_each            = toset(var.zero_din_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "zero_din_membership" {
  for_each         = data.azuread_user.zero_din_members
  group_object_id  = azuread_group.zero_din.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "relops" {
  display_name     = "Relops"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — RelOps team members"
}

data "azuread_user" "relops_members" {
  for_each            = toset(var.relops_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "relops_membership" {
  for_each         = data.azuread_user.relops_members
  group_object_id  = azuread_group.relops.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "releng" {
  display_name     = "Releng"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Release Engineering team"
}

data "azuread_user" "releng_members" {
  for_each            = toset(var.releng_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "releng_membership" {
  for_each         = data.azuread_user.releng_members
  group_object_id  = azuread_group.releng.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "tceng" {
  display_name     = "Taskcluster"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Taskcluster Engineering team"
}

data "azuread_user" "tceng_members" {
  for_each            = toset(var.tceng_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "tceng_membership" {
  for_each         = data.azuread_user.tceng_members
  group_object_id  = azuread_group.tceng.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "infrasec" {
  display_name     = "Infrastructure Security Team"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Infrastructure Security Team"
}

data "azuread_user" "infrasec_members" {
  for_each            = toset(var.infrasec_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "infrasec_membership" {
  for_each         = data.azuread_user.infrasec_members
  group_object_id  = azuread_group.infrasec.object_id
  member_object_id = each.value.object_id
}

# Role-assignable — controls billing access across CI subscriptions
resource "azuread_group" "ci_billing" {
  display_name       = "CI Billing"
  security_enabled   = true
  mail_enabled       = false
  assignable_to_role = true
  description        = "Managed by RelOps — Azure CI billing access"
}

data "azuread_user" "ci_billing_members" {
  for_each            = toset(var.ci_billing_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "ci_billing_membership" {
  for_each         = data.azuread_user.ci_billing_members
  group_object_id  = azuread_group.ci_billing.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "windows_testers" {
  display_name     = "WindowsTesters"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — members with Windows VMs for manual testing"
}

data "azuread_user" "windows_testers_members" {
  for_each            = toset(var.windows_testers_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "windows_testers_membership" {
  for_each         = data.azuread_user.windows_testers_members
  group_object_id  = azuread_group.windows_testers.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "firefox_enterprise_vms" {
  display_name     = "Firefox Enterprise VMs"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Firefox Enterprise VM access"
}

data "azuread_user" "firefox_enterprise_vms_members" {
  for_each            = toset(var.firefox_enterprise_vms_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "firefox_enterprise_vms_membership" {
  for_each         = data.azuread_user.firefox_enterprise_vms_members
  group_object_id  = azuread_group.firefox_enterprise_vms.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "firefox_desktop_vms" {
  display_name     = "Firefox Desktop VMs"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Firefox Desktop VM access"
}

data "azuread_user" "firefox_desktop_vms_members" {
  for_each            = toset(var.firefox_desktop_vms_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "firefox_desktop_vms_membership" {
  for_each         = data.azuread_user.firefox_desktop_vms_members
  group_object_id  = azuread_group.firefox_desktop_vms.object_id
  member_object_id = each.value.object_id
}

# Empty group with active role assignments — verify if intentional
resource "azuread_group" "security_engineering" {
  display_name     = "Security Engineering"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Security Engineering team"
}

data "azuread_user" "security_engineering_members" {
  for_each            = toset(var.security_engineering_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "security_engineering_membership" {
  for_each         = data.azuread_user.security_engineering_members
  group_object_id  = azuread_group.security_engineering.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "cognitive_services" {
  display_name     = "Cognitive Services"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Cognitive Services team (FF Non-CI access)"
}

data "azuread_user" "cognitive_services_members" {
  for_each            = toset(var.cognitive_services_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "cognitive_services_membership" {
  for_each         = data.azuread_user.cognitive_services_members
  group_object_id  = azuread_group.cognitive_services.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "data_sre" {
  display_name     = "Data SRE"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Data SRE team (FF Non-CI access)"
}

data "azuread_user" "data_sre_members" {
  for_each            = toset(var.data_sre_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "data_sre_membership" {
  for_each         = data.azuread_user.data_sre_members
  group_object_id  = azuread_group.data_sre.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "passkey_poc" {
  display_name     = "Passkey_PoC"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Passkey proof-of-concept group"
}

data "azuread_user" "passkey_poc_members" {
  for_each            = toset(var.passkey_poc_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "passkey_poc_membership" {
  for_each         = data.azuread_user.passkey_poc_members
  group_object_id  = azuread_group.passkey_poc.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "macos_windows_sso_testing" {
  display_name     = "macOS Windows SSO Testing"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — macOS/Windows SSO testing group"
}

data "azuread_user" "macos_windows_sso_testing_members" {
  for_each            = toset(var.macos_windows_sso_testing_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "macos_windows_sso_testing_membership" {
  for_each         = data.azuread_user.macos_windows_sso_testing_members
  group_object_id  = azuread_group.macos_windows_sso_testing.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "service_desk" {
  display_name     = "Service Desk"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Service Desk group"
}

data "azuread_user" "service_desk_members" {
  for_each            = toset(var.service_desk_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "service_desk_membership" {
  for_each         = data.azuread_user.service_desk_members
  group_object_id  = azuread_group.service_desk.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "webrtc_group" {
  display_name     = "WebRTC Group"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — WebRTC team group"
}

data "azuread_user" "webrtc_group_members" {
  for_each            = toset(var.webrtc_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "webrtc_group_membership" {
  for_each         = data.azuread_user.webrtc_group_members
  group_object_id  = azuread_group.webrtc_group.object_id
  member_object_id = each.value.object_id
}

# Contributor on FXCI main CI subscription
resource "azuread_group" "seio" {
  display_name     = "SEIO"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — SEIO group"
}

data "azuread_user" "seio_members" {
  for_each            = toset(var.seio_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "seio_membership" {
  for_each         = data.azuread_user.seio_members
  group_object_id  = azuread_group.seio.object_id
  member_object_id = each.value.object_id
}

# No Azure RBAC — membership grants access via MS Store Partner Center portal
resource "azuread_group" "ms_store_publishers" {
  display_name     = "Microsoft Store Publishers"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Microsoft Store publishing access (Partner Center)"
}

data "azuread_user" "ms_store_publishers_members" {
  for_each            = toset(var.ms_store_publishers_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "ms_store_publishers_membership" {
  for_each         = data.azuread_user.ms_store_publishers_members
  group_object_id  = azuread_group.ms_store_publishers.object_id
  member_object_id = each.value.object_id
}

# No Azure RBAC — verify with Mike Kaply if still needed
resource "azuread_group" "policy_testing" {
  display_name     = "Policy Testing"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Firefox enterprise policy testing group"
}

data "azuread_user" "policy_testing_members" {
  for_each            = toset(var.policy_testing_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "policy_testing_membership" {
  for_each         = data.azuread_user.policy_testing_members
  group_object_id  = azuread_group.policy_testing.object_id
  member_object_id = each.value.object_id
}

# No Azure RBAC — membership grants access via MS Store Partner Center portal
resource "azuread_group" "ms_store_finance" {
  display_name     = "Microsoft Store Finance"
  security_enabled = true
  mail_enabled     = false
  description      = "Managed by RelOps — Microsoft Store finance access (Partner Center)"
}

data "azuread_user" "ms_store_finance_members" {
  for_each            = toset(var.ms_store_finance_group)
  user_principal_name = each.value
}

resource "azuread_group_member" "ms_store_finance_membership" {
  for_each         = data.azuread_user.ms_store_finance_members
  group_object_id  = azuread_group.ms_store_finance.object_id
  member_object_id = each.value.object_id
}
