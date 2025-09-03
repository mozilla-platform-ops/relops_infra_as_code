<!-- BEGIN_TF_DOCS -->
# wiz-azure-outpost-connector-terraform #

A Terraform module to create an Azure Outpost connector with Wiz.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.83, < 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.83, < 4.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.sp_grant_role_consent](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.wiz_for_azure](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_role_assignment.wiz_custom_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_data_scanning_role_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_disk_analyzer_role_custom_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_disk_analyzer_role_storage_blob_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_disk_analyzer_role_storage_file_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_openai_scanning_role_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_da_scanner_serverless_scanning_role_assign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_k8s_cluster_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_k8s_rbac_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_openai_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.wiz_reader_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.wiz_custom_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_data_scanning_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_disk_analyzer_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.wiz_serverless_scanning_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [time_sleep.wait_for_az_dataplane_data_roles](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_azure_dataplane_custom_role](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_service_principal.wiz_da_scanner_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_service_principal.wiz_for_azure](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_wiz_app_id"></a> [wiz\_app\_id](#input\_wiz\_app\_id) | Client ID of your Wiz's tenant managed Entra ID application. | `string` | n/a | yes |
| <a name="input_azure_environment"></a> [azure\_environment](#input\_azure\_environment) | DEPRECATED: This variable is deprecated and will be removed in a future release. Please set this in your terraform provider block instead.<br/><br/>    The Cloud Environment which should be used, possible values are: public, usgovernment, german, and china.<br/>    Defaults to public. | `string` | `"public"` | no |
| <a name="input_azure_management_group_id"></a> [azure\_management\_group\_id](#input\_azure\_management\_group\_id) | If set, will add role assignments for the wiz application to the management group.<br/>    Takes precedence over subscription\_id. | `string` | `""` | no |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | If set, will add role assignments for the wiz application to the subscription.<br/>    If management\_group\_id is set, it takes precedence. | `string` | `""` | no |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | The Azure tenant ID for the deployment | `string` | `""` | no |
| <a name="input_azure_wait_timer"></a> [azure\_wait\_timer](#input\_azure\_wait\_timer) | (Optional) Wait timer for Azure dataplane propagation - Default: 600 | `string` | `"600s"` | no |
| <a name="input_enable_data_scanning"></a> [enable\_data\_scanning](#input\_enable\_data\_scanning) | If set, adds data scanning required permissions to the Wiz custom role. Default is false. | `bool` | `false` | no |
| <a name="input_enable_entra_id_scanning"></a> [enable\_entra\_id\_scanning](#input\_enable\_entra\_id\_scanning) | If set, adds permissions for Entra ID scanning to the Azure Service Principal. Default is false. | `bool` | `false` | no |
| <a name="input_enable_openai_scanning"></a> [enable\_openai\_scanning](#input\_enable\_openai\_scanning) | If set, adds the required role for OpenAI scanning by Wiz. Default is false. | `bool` | `false` | no |
| <a name="input_enable_serverless_scanning"></a> [enable\_serverless\_scanning](#input\_enable\_serverless\_scanning) | If set, adds serverless scanning required permissions to the Wiz custom role. Default is false. | `bool` | `false` | no |
| <a name="input_use_existing_service_principal"></a> [use\_existing\_service\_principal](#input\_use\_existing\_service\_principal) | If set to true, use an existing service principal instead of creating a new one. | `bool` | `false` | no |
| <a name="input_wiz_app_object_id"></a> [wiz\_app\_object\_id](#input\_wiz\_app\_object\_id) | (Optional) The object ID of an existing service principal to use directly.<br/>    If provided, this will bypass the lookup by client\_id/app\_id and use this object\_id directly.<br/>    This is useful when the service principal lookup by client\_id fails in the environment. | `string` | `""` | no |
| <a name="input_wiz_custom_role_name"></a> [wiz\_custom\_role\_name](#input\_wiz\_custom\_role\_name) | (Optional) The name of the Azure custom role to create. Defaults to WizCustomRole. | `string` | `"WizCustomRole"` | no |
| <a name="input_wiz_da_scanner_app_id"></a> [wiz\_da\_scanner\_app\_id](#input\_wiz\_da\_scanner\_app\_id) | Client ID of your Wiz's tenant managed DA Scanner application. | `string` | `""` | no |
| <a name="input_wiz_data_scanning_role_name"></a> [wiz\_data\_scanning\_role\_name](#input\_wiz\_data\_scanning\_role\_name) | (Optional) The name of the Wiz custom data scanning role | `string` | `"WizDataScanningRole"` | no |
| <a name="input_wiz_disk_analyzer_role_name"></a> [wiz\_disk\_analyzer\_role\_name](#input\_wiz\_disk\_analyzer\_role\_name) | (Optional) The name of the Wiz custom disk scanning role | `string` | `"WizDiskAnalyzerRole"` | no |
| <a name="input_wiz_serverless_scanning_role_name"></a> [wiz\_serverless\_scanning\_role\_name](#input\_wiz\_serverless\_scanning\_role\_name) | (Optional) The name of the Wiz custom serverless scanning role | `string` | `"WizServerlessScanningRole"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_tenant_id"></a> [azure\_tenant\_id](#output\_azure\_tenant\_id) | n/a |
| <a name="output_management_group_id"></a> [management\_group\_id](#output\_management\_group\_id) | n/a |
| <a name="output_outpost_secret_name"></a> [outpost\_secret\_name](#output\_outpost\_secret\_name) | n/a |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | n/a |
| <a name="output_wiz_app_id"></a> [wiz\_app\_id](#output\_wiz\_app\_id) | n/a |
| <a name="output_wiz_da_scanner_app_id"></a> [wiz\_da\_scanner\_app\_id](#output\_wiz\_da\_scanner\_app\_id) | n/a |
<!-- END_TF_DOCS -->