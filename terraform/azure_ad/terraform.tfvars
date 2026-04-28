tag_project_name     = "azure_ad"
tag_production_state = "production"
tag_owner_email      = "relops@mozilla.com"

## TODO: Add method that will prevent duplicate entries of sub IDs
# Subscription IDs (no "Azure subscription 1" entries)
fxci_devtest_subscription_id  = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
taskcluster_subscription_id   = "8a205152-b25a-417f-a676-80465535a6c9"
trusted_fxci_subscription_id  = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
infra_sec_subscription_id     = "9b9774fb-67f1-45b7-830f-aafe07a94396"
firefox_nonci_subscription_id = "0a420ff9-bc77-4475-befc-a05071fc92ec"
zero_din_subscription_id      = "e1cb04e4-3788-471a-881f-385e66ad80ab"

azure_subscriptions = [
  "/subscriptions/0a420ff9-bc77-4475-befc-a05071fc92ec",
  "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0",
  "/subscriptions/8a205152-b25a-417f-a676-80465535a6c9",
  "/subscriptions/a30e97ab-734a-4f3b-a0e4-c51c0bff0701",
  "/subscriptions/9b9774fb-67f1-45b7-830f-aafe07a94396",
  "/subscriptions/e1cb04e4-3788-471a-881f-385e66ad80ab"
]

# 0DIN group membership
zero_din_group = [
  "mfigueroa@mozilla.com",
  "pamini@mozilla.com",
  "reddings@mozilla.com",
  "aminali@mozilla.com",
  "jmcbride@mozilla.com",
  "operevertailo@mozilla.com",
  "tritchie@mozilla.com",
]

# Populate from: az ad group member list --group "Relops" --query "[].userPrincipalName" -o tsv
relops_group = []

# Populate from: az ad group member list --group "Releng" --query "[].userPrincipalName" -o tsv
releng_group = []

# Populate from: az ad group member list --group "Taskcluster" --query "[].userPrincipalName" -o tsv
tceng_group = []

# Populate from: az ad group member list --group "Infrastructure Security Team" --query "[].userPrincipalName" -o tsv
infrasec_group = []

# Populate from: az ad group member list --group "CI Billing" --query "[].userPrincipalName" -o tsv
ci_billing_group = []

# Known members: Greg Stoll, jmaher — verify UPNs with: az ad group member list --group "WindowsTesters" --query "[].userPrincipalName" -o tsv
windows_testers_group = []

# Known members: Kershaw Jang, Mike Kaply — verify UPNs with: az ad group member list --group "Firefox Enterprise VMs" --query "[].userPrincipalName" -o tsv
firefox_enterprise_vms_group = []

# Known members: David Rubino — verify UPNs with: az ad group member list --group "Firefox Desktop VMs" --query "[].userPrincipalName" -o tsv
firefox_desktop_vms_group = []

# Empty group — verify if intentional: az ad group member list --group "Security Engineering" --query "[].userPrincipalName" -o tsv
security_engineering_group = []

# Known members: Evgeny Pavlov — verify UPNs with: az ad group member list --group "Cognitive Services" --query "[].userPrincipalName" -o tsv
cognitive_services_group = []

# Known members: Alekhya Reddy Kommasani, Arkadiusz Komarzewski, Curtis Morales, Wesley Dawson
# Verify UPNs with: az ad group member list --group "Data SRE" --query "[].userPrincipalName" -o tsv
data_sre_group = []

# Known members: Andreas Wagner, Dimitri Kirchner, Jonathan Moss
# Verify UPNs with: az ad group member list --group "Passkey_PoC" --query "[].userPrincipalName" -o tsv
passkey_poc_group = []

# Known members: Kershaw Jang, Mike Kaply — verify UPNs with: az ad group member list --group "macOS Windows SSO Testing" --query "[].userPrincipalName" -o tsv
macos_windows_sso_testing_group = []

# Empty group — az ad group member list --group "Service Desk" --query "[].userPrincipalName" -o tsv
service_desk_group = []

# Known members: Jan-Ivar Bruaroey, Jim Mathies — verify UPNs with: az ad group member list --group "WebRTC Group" --query "[].userPrincipalName" -o tsv
webrtc_group = []

# Known members: Mike Kaply — verify UPNs with: az ad group member list --group "Policy Testing" --query "[].userPrincipalName" -o tsv
policy_testing_group = []

# Known members: Chris Brentano (cbrentano@mozilla.com) — verify with: az ad group member list --group "SEIO" --query "[].userPrincipalName" -o tsv
seio_group = []

# Known members: Amir Habibi, Ben Hearsum, Chris DuPuis, David Rubino, Dianna Smith, Jonathan Moss,
#   Julia Gibbs, Julien Cristau, Mark Cornmesser, Marlene Hirose, nalexander, Noel De La Torre,
#   Pascal Chevrel, Romain Testard, Ryan VanderMeulen + 2 others
# Verify UPNs with: az ad group member list --group "Microsoft Store Publishers" --query "[].userPrincipalName" -o tsv
ms_store_publishers_group = []

# Known members: Alex Davis, Amir Habibi, Ben Hearsum, David Rubino, Julia Gibbs, Julien Cristau,
#   Lauren Niolet, Mark Cornmesser, Mark Toubman, Marlene Hirose, Nadia Florez, Noel De La Torre,
#   Norberto Andres Furlan, Richard Baffour-Awuah, Romain Testard, Ryan VanderMeulen, Su-Young Hong + 1 other
# Verify UPNs with: az ad group member list --group "Microsoft Store Finance" --query "[].userPrincipalName" -o tsv
ms_store_finance_group = []
