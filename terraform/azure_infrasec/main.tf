locals {
  infra_sec_subscription = "9b9774fb-67f1-45b7-830f-aafe07a94396"
  mozilla_tenant_id      = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

module "wiz_azure_outpost" {
  source                                 = "./wiz_azure_outpost"
  azure_tenant_id                        = local.mozilla_tenant_id
  azure_subscription_id                  = local.infra_sec_subscription
  wiz_application_keyvault_name          = "kv-wiz-moz"
  wiz_global_orchestrator_rg_name        = "rg-wiz-global-orchestrator"
  wiz_global_orchestrator_rg_region      = "westus2"
  wiz_da_orchestrator_wiz_managed_app_id = "dfff79c9-64b2-475a-8217-0f84e7ab96e9"
  enable_data_scanning                   = true
  use_worker_managed_identity            = true
}

# module "wiz_azure_outpost_connector" {
#   source = "./wiz_azure_outpost_connector"

#   #azure_management_group_id      = local.mozilla_tenant_id
#   azure_subscription_id          = local.infra_sec_subscription
#   use_existing_service_principal = true
#   wiz_app_id                     = "dfff79c9-64b2-475a-8217-0f84e7ab96e9"
#   wiz_da_scanner_app_id          = module.wiz_azure_outpost.wiz_da_scanner_client_id
#   #use_managed_orchestrator   = true
#   enable_data_scanning       = true
#   enable_serverless_scanning = false
#   enable_openai_scanning     = false
#   enable_entra_id_scanning   = false
# }
