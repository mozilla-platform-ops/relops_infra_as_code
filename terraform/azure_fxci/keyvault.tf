locals {
  tenant_id               = "c0dc8bb0-b616-427e-8217-9513964a145b"
  location                = "Central US"
  locationshort           = "central-us"
  relops_object_id        = "cb79b99f-fdaa-4e0d-a2c8-c5841890fa74"
  worker_images_object_id = "74bce7ad-06b0-4fbd-9f89-be87a691d682"
}

resource "azurerm_resource_group" "cot" {
  name     = "rg-${local.locationshort}-cot"
  location = local.location
  tags     = {
    terraform       = "true"
    source_repo_url = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
}

resource "azurerm_key_vault" "cot" {
  name                = "kv-${local.locationshort}-key"
  location            = azurerm_resource_group.cot.location
  resource_group_name = azurerm_resource_group.cot.name
  tenant_id           = local.tenant_id
  sku_name            = "standard"

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
