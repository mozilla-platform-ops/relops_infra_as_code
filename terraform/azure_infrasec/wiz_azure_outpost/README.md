<!-- BEGIN_TF_DOCS -->
# wiz-azure-outpost-automated-terraform #

A Terraform module to create an Azure automated Outpost with Wiz.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.46 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.83 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.46 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.83 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.wiz_da_orchestrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.wiz_da_scanner](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.wiz_da_worker](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_certificate.wiz_da_scanner_certificate](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_certificate) | resource |
| [azuread_application_password.wiz_da_orchestrator_pass](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_application_password.wiz_da_scanner_pass](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_application_password.wiz_da_worker_pass](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.wiz_da_orchestrator_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.wiz_da_scanner_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.wiz_da_worker_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault.wiz_outpost_keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_certificate.wiz_da_scanner_certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_key_vault_secret.wiz_da_scanner_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.wiz_da_worker_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_resource_group.wiz_orchestrator_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.wiz_da_control_plane_managed_id_operator_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_orchestrator_managed_id_operator_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_orchestrator_wiz_orch_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_orchestrator_wiz_orch_assign_byon](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_azure_wiz_da_diskcopy_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_wiz_da_datascanning_copy_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_worker_azure_vm_contributor_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_worker_wiz_da_datascanning_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_worker_wiz_orch_disk_manager_worker_role_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.wiz_diskanalyzer_datascanning_copy_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_diskanalyzer_datascanning_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_diskanalyzer_diskcopy_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_orch_diskanalyzer_diskmanager_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_orchestrator_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_orchestrator_role_byon](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.wiz_da_control_plane_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.wiz_da_worker_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [time_sleep.wait_for_az_dataplane](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | (Required) The Azure subscription id where you want to deploy the Wiz outpost | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | (Required) The Azure Tenant ID | `string` | n/a | yes |
| <a name="input_enable_data_scanning"></a> [enable\_data\_scanning](#input\_enable\_data\_scanning) | (Optional) Enable data scanning - Default: false | `bool` | n/a | yes |
| <a name="input_wiz_application_keyvault_name"></a> [wiz\_application\_keyvault\_name](#input\_wiz\_application\_keyvault\_name) | (Required) The name of the vault used by Wiz outpost | `string` | n/a | yes |
| <a name="input_wiz_global_orchestrator_rg_region"></a> [wiz\_global\_orchestrator\_rg\_region](#input\_wiz\_global\_orchestrator\_rg\_region) | (Required) The Azure region for the Wiz resource group | `string` | n/a | yes |
| <a name="input_azure_wait_timer"></a> [azure\_wait\_timer](#input\_azure\_wait\_timer) | (Optional) Wait timer for Azure dataplane propagation - Default: 600 | `string` | `"600s"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) The terraform environment to deploy into - Default: public. Options: public, usgovernment, german, china | `string` | `"public"` | no |
| <a name="input_key_expire_end_date_relative"></a> [key\_expire\_end\_date\_relative](#input\_key\_expire\_end\_date\_relative) | (Optional) Hours for password expiration for Wiz apps - Default: 87600h = 24h * 365 days * 10 years | `string` | `"87600h"` | no |
| <a name="input_multi_tenancy_enabled"></a> [multi\_tenancy\_enabled](#input\_multi\_tenancy\_enabled) | (Optional) Enable the Wiz Disk Analyzer - Scanner app for multi-tenant usage - Default: false | `bool` | `false` | no |
| <a name="input_scanner_app_key_vault_certificate_pem_file_path"></a> [scanner\_app\_key\_vault\_certificate\_pem\_file\_path](#input\_scanner\_app\_key\_vault\_certificate\_pem\_file\_path) | (Optional) The path to the pem file for the Scanner app key vault certificate | `string` | `null` | no |
| <a name="input_self-managed-network"></a> [self-managed-network](#input\_self-managed-network) | Use auto/manual network. False (default): regular Outpost. True: Self-managed network Outpost. | `bool` | `false` | no |
| <a name="input_use_worker_managed_identity"></a> [use\_worker\_managed\_identity](#input\_use\_worker\_managed\_identity) | (Optional) create a worker managed identity instead of worker app | `bool` | `false` | no |
| <a name="input_wiz_custom_data_scanning_copy_role_name"></a> [wiz\_custom\_data\_scanning\_copy\_role\_name](#input\_wiz\_custom\_data\_scanning\_copy\_role\_name) | (Optional) Name of the custom Wiz role - Default: WizDataCopyCustomRole | `string` | `"WizDataCopyCustomRole"` | no |
| <a name="input_wiz_custom_data_scanning_role_name"></a> [wiz\_custom\_data\_scanning\_role\_name](#input\_wiz\_custom\_data\_scanning\_role\_name) | (Optional) Name of the custom Wiz role - Default: WizOrchestratorDataScanningRole | `string` | `"WizOrchestratorDataScanningRole"` | no |
| <a name="input_wiz_custom_disk_copy_role_name"></a> [wiz\_custom\_disk\_copy\_role\_name](#input\_wiz\_custom\_disk\_copy\_role\_name) | (Optional) Name of the custom Wiz role - Default: WizDiskCopyCustomRole | `string` | `"WizDiskCopyCustomRole"` | no |
| <a name="input_wiz_custom_orch_disk_manager_worker_role_name"></a> [wiz\_custom\_orch\_disk\_manager\_worker\_role\_name](#input\_wiz\_custom\_orch\_disk\_manager\_worker\_role\_name) | (Optional) Name of the custom Wiz role - Default: WizOrchestratorDiskmanagerWorkerRole | `string` | `"WizOrchestratorDiskmanagerWorkerRole"` | no |
| <a name="input_wiz_custom_orchestrator_role_name"></a> [wiz\_custom\_orchestrator\_role\_name](#input\_wiz\_custom\_orchestrator\_role\_name) | (Optional) Name of the custom Wiz role - Default: WizOrchestratorRole | `string` | `"WizOrchestratorRole"` | no |
| <a name="input_wiz_da_control_plane_identity_name"></a> [wiz\_da\_control\_plane\_identity\_name](#input\_wiz\_da\_control\_plane\_identity\_name) | (Optional) control plane identity name - Default: WizControlPlaneIdentity | `string` | `"WizControlPlaneIdentity"` | no |
| <a name="input_wiz_da_orchestrator_app_name"></a> [wiz\_da\_orchestrator\_app\_name](#input\_wiz\_da\_orchestrator\_app\_name) | (Optional) Name of the Wiz Disk Analyzer - Orchestrator app - Default: Wiz Disk Analyzer - Orchestrator | `string` | `"Wiz Disk Analyzer - Orchestrator"` | no |
| <a name="input_wiz_da_orchestrator_wiz_managed_app_id"></a> [wiz\_da\_orchestrator\_wiz\_managed\_app\_id](#input\_wiz\_da\_orchestrator\_wiz\_managed\_app\_id) | Client ID of your Wiz's tenant managed Entra ID application. | `string` | `"00000000-0000-0000-0000-000000000000"` | no |
| <a name="input_wiz_da_scanner_app_name"></a> [wiz\_da\_scanner\_app\_name](#input\_wiz\_da\_scanner\_app\_name) | (Optional) Name of the Wiz Disk Analyzer - Scanner app - Default: Wiz Disk Analyzer - Scanner | `string` | `"Wiz Disk Analyzer - Scanner"` | no |
| <a name="input_wiz_da_scanner_app_secret"></a> [wiz\_da\_scanner\_app\_secret](#input\_wiz\_da\_scanner\_app\_secret) | (Optional) A secret for the Wiz Disk Analyzer - Scanner app - Default: wiz\_auto\_create\_pass - create a secret automatically | `string` | `"wiz_auto_create_secret"` | no |
| <a name="input_wiz_da_worker_app_name"></a> [wiz\_da\_worker\_app\_name](#input\_wiz\_da\_worker\_app\_name) | (Optional) Name of the Wiz Disk Analyzer - Worker app - Default: Wiz Disk Analyzer - Worker | `string` | `"Wiz Disk Analyzer - Worker"` | no |
| <a name="input_wiz_da_worker_app_secret"></a> [wiz\_da\_worker\_app\_secret](#input\_wiz\_da\_worker\_app\_secret) | (Optional) A secret for the Wiz Disk Analyzer - Worker app - Default: wiz\_auto\_create\_pass - create a secret automatically | `string` | `"wiz_auto_create_secret"` | no |
| <a name="input_wiz_da_worker_identity_name"></a> [wiz\_da\_worker\_identity\_name](#input\_wiz\_da\_worker\_identity\_name) | (Optional) worker managed identity name - Default: WizWorkerIdentity | `string` | `"WizWorkerIdentity"` | no |
| <a name="input_wiz_global_orchestrator_rg_name"></a> [wiz\_global\_orchestrator\_rg\_name](#input\_wiz\_global\_orchestrator\_rg\_name) | (Optional) The name for the Wiz Resource group name - Default: wiz-orchestrator-global-rg | `string` | `"wiz-orchestrator-global-rg"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_subscription_id"></a> [azure\_subscription\_id](#output\_azure\_subscription\_id) | Azure Subscription ID |
| <a name="output_azure_tenant_id"></a> [azure\_tenant\_id](#output\_azure\_tenant\_id) | Azure Tenant ID |
| <a name="output_wiz_application_keyvault_name"></a> [wiz\_application\_keyvault\_name](#output\_wiz\_application\_keyvault\_name) | Application keyvault name |
| <a name="output_wiz_da_control_plane_managed_identity_id"></a> [wiz\_da\_control\_plane\_managed\_identity\_id](#output\_wiz\_da\_control\_plane\_managed\_identity\_id) | Worker Managed Identity ID |
| <a name="output_wiz_da_orch_app_name"></a> [wiz\_da\_orch\_app\_name](#output\_wiz\_da\_orch\_app\_name) | Orchestrator App Name |
| <a name="output_wiz_da_orchestrator_client_id"></a> [wiz\_da\_orchestrator\_client\_id](#output\_wiz\_da\_orchestrator\_client\_id) | Orchestrator Client ID |
| <a name="output_wiz_da_orchestrator_client_secret"></a> [wiz\_da\_orchestrator\_client\_secret](#output\_wiz\_da\_orchestrator\_client\_secret) | Orchestrator Client Secret |
| <a name="output_wiz_da_scanner_app_name"></a> [wiz\_da\_scanner\_app\_name](#output\_wiz\_da\_scanner\_app\_name) | Scanner App Name |
| <a name="output_wiz_da_scanner_client_id"></a> [wiz\_da\_scanner\_client\_id](#output\_wiz\_da\_scanner\_client\_id) | Scanner Client ID |
| <a name="output_wiz_da_scanner_client_secret"></a> [wiz\_da\_scanner\_client\_secret](#output\_wiz\_da\_scanner\_client\_secret) | Scanner Client Secret |
| <a name="output_wiz_da_worker_app_name"></a> [wiz\_da\_worker\_app\_name](#output\_wiz\_da\_worker\_app\_name) | Worker App Name |
| <a name="output_wiz_da_worker_client_id"></a> [wiz\_da\_worker\_client\_id](#output\_wiz\_da\_worker\_client\_id) | Worker Client ID |
| <a name="output_wiz_da_worker_client_secret"></a> [wiz\_da\_worker\_client\_secret](#output\_wiz\_da\_worker\_client\_secret) | Worker Client Secret |
| <a name="output_wiz_da_worker_managed_identity_client_id"></a> [wiz\_da\_worker\_managed\_identity\_client\_id](#output\_wiz\_da\_worker\_managed\_identity\_client\_id) | Worker Managed Identity Client ID |
| <a name="output_wiz_da_worker_managed_identity_id"></a> [wiz\_da\_worker\_managed\_identity\_id](#output\_wiz\_da\_worker\_managed\_identity\_id) | Worker Managed Identity ID |
| <a name="output_wiz_resource_group_name"></a> [wiz\_resource\_group\_name](#output\_wiz\_resource\_group\_name) | Resource group name |
<!-- END_TF_DOCS -->