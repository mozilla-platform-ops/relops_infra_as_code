locals {
  infra_sec_subscription = "9b9774fb-67f1-45b7-830f-aafe07a94396"
  mozilla_tenant_id      = "c0dc8bb0-b616-427e-8217-9513964a145b"
}

module "wiz_azure_outpost" {
  source                = "./wiz_azure_outpost"
  azure_tenant_id       = local.mozilla_tenant_id
  azure_subscription_id = local.infra_sec_subscription

  wiz_application_keyvault_name     = ""
  wiz_global_orchestrator_rg_name   = ""
  wiz_global_orchestrator_rg_region = ""

  enable_data_scanning                   = true
  use_worker_managed_identity            = true
  wiz_da_orchestrator_wiz_managed_app_id = "dfff79c9-64b2-475a-8217-0f84e7ab96e9"
  # The following defaults can be changed if you need different names or if you have an existing deployment on the same account
  wiz_custom_orch_disk_manager_worker_role_name = "WizOrchestratorDiskmanagerWorkerRole"
  wiz_custom_orchestrator_role_name             = "WizOrchestratorRole"
  wiz_custom_data_scanning_role_name            = "WizOrchestratorDataScanningRole"
  wiz_custom_data_scanning_copy_role_name       = "WizDataCopyCustomRole"
  wiz_custom_disk_copy_role_name                = "WizDiskCopyCustomRole"
}
