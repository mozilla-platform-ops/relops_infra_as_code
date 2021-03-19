locals {
  sp_tags = [for k, v in local.common_tags : join(":", [k, v])]
}

resource "azuread_application" "CloudImageBuilder" {
  display_name = "CloudImageBuilder"
}
resource "azuread_service_principal" "CloudImageBuilder" {
  application_id = azuread_application.CloudImageBuilder.application_id

  tags = concat(["name:CloudImageBuilder"], local.sp_tags)
}

resource "azuread_application" "Packer_Through_CIB" {
  display_name = "Packer_Through_CIB"
}
resource "azuread_service_principal" "Packer_Through_CIB" {
  application_id = azuread_application.Packer_Through_CIB.application_id

  tags = concat(["name:Packer_Through_CIB"], local.sp_tags)
}

resource "azuread_application" "taskcluster-worker-manager-production" {
  display_name = "taskcluster-worker-manager-production"
}
resource "azuread_service_principal" "taskcluster-worker-manager-production" {
  application_id = azuread_application.taskcluster-worker-manager-production.application_id

  tags = concat(["name:taskcluster-worker-manager-production"], local.sp_tags)
}

resource "azuread_application" "taskcluster-worker-manager-staging" {
  display_name = "taskcluster-worker-manager-staging"
}
resource "azuread_service_principal" "taskcluster-worker-manager-staging" {
  application_id = azuread_application.taskcluster-worker-manager-staging.application_id

  tags = concat(["name:taskcluster-worker-manager-staging"], local.sp_tags)
}
