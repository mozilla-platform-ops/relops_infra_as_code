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
