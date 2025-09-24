locals {
  tags = {
    terraform       = "true"
    source_repo_url = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  tenant_id               = "c0dc8bb0-b616-427e-8217-9513964a145b"
  location                = "Central US"
  locationshort           = "central-us"
  relops_object_id        = "cb79b99f-fdaa-4e0d-a2c8-c5841890fa74"
  worker_images_object_id = "545b9db8-f89c-4380-becf-79316c396a16"
}

resource "azurerm_resource_group" "cot" {
  name     = "rg-${local.locationshort}-cot"
  location = local.location
  tags     = local.tags
}

resource "azurerm_key_vault" "cot" {
  name                = "kv-${local.locationshort}-cot"
  location            = azurerm_resource_group.cot.location
  resource_group_name = azurerm_resource_group.cot.name
  tenant_id           = local.tenant_id
  sku_name            = "standard"

  # Access policy for the current user/service principal running Terraform
  access_policy {
    tenant_id = local.tenant_id
    object_id = local.relops_object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
    ]
  }

  access_policy {
    tenant_id = local.tenant_id
    object_id = local.worker_images_object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
    ]
  }
}
