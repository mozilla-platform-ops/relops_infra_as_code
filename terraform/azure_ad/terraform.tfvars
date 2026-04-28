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

# UPNs below are derived from display names in RELOPS-2345. Verify all with:
# az ad group member list --group "<name>" --query "[].userPrincipalName" -o tsv

# Andrew Erickson, Jonathan Moss, Julia Gibbs, Mark Cornmesser
relops_group = [
  "aerickson@mozilla.com",
  "jmoss@mozilla.com",
  "jgibbs@mozilla.com",
  "mcornmesser@mozilla.com",
]

# Heitor Neiva, Julien Cristau
releng_group = [
  "hneiva@mozilla.com",
  "jcristau@mozilla.com",
]

# Matt Boris, Pete Moore, Yaraslau Kurmyza
tceng_group = [
  "mboris@mozilla.com",
  "pmoore@mozilla.com",
  "ykurmyza@mozilla.com",
]

# Ash Syed, Clovis Foji, Dimitri Kirchner, Rachel Pohl, Sandeep Seehra
infrasec_group = [
  "asyed@mozilla.com",
  "cfoji@mozilla.com",
  "dkirchn@mozilla.com",
  "rpohl@mozilla.com",
  "sseehra@mozilla.com",
]

# André Honeiser, Jason Thomas, Julien Cristau, Kristin Prust, Mikaël Ducharme, Sylvestre Ledru
ci_billing_group = [
  "ahoneiser@mozilla.com",
  "jthomas@mozilla.com",
  "jcristau@mozilla.com",
  "kprust@mozilla.com",
  "mducharme@mozilla.com",
  "sledru@mozilla.com",
]

# Greg Stoll, jmaher
windows_testers_group = [
  "gstoll@mozilla.com",
  "jmaher@mozilla.com",
]

# Kershaw Jang, Mike Kaply
firefox_enterprise_vms_group = [
  "kjang@mozilla.com",
  "mkaply@mozilla.com",
]

# David Rubino
firefox_desktop_vms_group = [
  "drubino@mozilla.com",
]

# Currently empty in Azure — confirm before adding members
security_engineering_group = []

# Evgeny Pavlov
cognitive_services_group = [
  "epavlov@mozilla.com",
]

# Alekhya Reddy Kommasani, Arkadiusz Komarzewski, Curtis Morales, Wesley Dawson
data_sre_group = [
  "akommasani@mozilla.com",
  "akomarzewski@mozilla.com",
  "cmorales@mozilla.com",
  "wdawson@mozilla.com",
]

# Andreas Wagner, Dimitri Kirchner, Jonathan Moss
passkey_poc_group = [
  "awagner@mozilla.com",
  "dkirchn@mozilla.com",
  "jmoss@mozilla.com",
]

# Kershaw Jang, Mike Kaply
macos_windows_sso_testing_group = [
  "kjang@mozilla.com",
  "mkaply@mozilla.com",
]

# Currently empty in Azure
service_desk_group = []

# Jan-Ivar Bruaroey, Jim Mathies
webrtc_group = [
  "jbruaroey@mozilla.com",
  "jmathies@mozilla.com",
]

# Mike Kaply
policy_testing_group = [
  "mkaply@mozilla.com",
]

# Chris Brentano
seio_group = [
  "cbrentano@mozilla.com",
]

# Amir Habibi, Ben Hearsum, Chris DuPuis, David Rubino, Dianna Smith, Jonathan Moss,
# Julia Gibbs, Julien Cristau, Mark Cornmesser, Markco Test (test account), Marlene Hirose,
# nalexander, Noel De La Torre, Pascal Chevrel, rkelimutu, Romain Testard, Ryan VanderMeulen
ms_store_publishers_group = [
  "ahabibi@mozilla.com",
  "bhearsum@mozilla.com",
  "cdupuis@mozilla.com",
  "drubino@mozilla.com",
  "dsmith@mozilla.com",
  "jmoss@mozilla.com",
  "jgibbs@mozilla.com",
  "jcristau@mozilla.com",
  "mcornmesser@mozilla.com",
  "markco_test@mozilla.com",
  "mhirose@mozilla.com",
  "nalexander@mozilla.com",
  "ndelatorre@mozilla.com",
  "pchevrel@mozilla.com",
  "rkelimutu@mozilla.com",
  "rtestard@mozilla.com",
  "rvandermeulen@mozilla.com",
]

# Alex Davis, Amir Habibi, Ben Hearsum, David Rubino, Julia Gibbs, Julien Cristau,
# Lauren Niolet, Mark Cornmesser, Mark Toubman, Markco Test (test account), Marlene Hirose,
# Nadia Florez, Noel De La Torre, Norberto Andres Furlan, Richard Baffour-Awuah,
# Romain Testard, Ryan VanderMeulen, Su-Young Hong
ms_store_finance_group = [
  "adavis@mozilla.com",
  "ahabibi@mozilla.com",
  "bhearsum@mozilla.com",
  "drubino@mozilla.com",
  "jgibbs@mozilla.com",
  "jcristau@mozilla.com",
  "lniolet@mozilla.com",
  "mcornmesser@mozilla.com",
  "mtoubman@mozilla.com",
  "markco_test@mozilla.com",
  "mhirose@mozilla.com",
  "nflorez@mozilla.com",
  "ndelatorre@mozilla.com",
  "nafurlan@mozilla.com",
  "rbaffour@mozilla.com",
  "rtestard@mozilla.com",
  "rvandermeulen@mozilla.com",
  "syhong@mozilla.com",
]
