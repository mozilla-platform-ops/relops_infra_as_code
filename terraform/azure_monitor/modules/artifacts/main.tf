locals {
  sa_base = lower(replace("${var.name}sa", "/[^a-z0-9]/", ""))
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_storage_account" "sa" {
  name                     = substr("${local.sa_base}${random_string.suffix.result}", 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "c" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "script" {
  name                   = var.script_blob_name
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.c.name
  type                   = "Block"
  source                 = var.script_local_path
  content_type           = "text/plain"
}

data "azurerm_storage_account_sas" "blob_sas" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  start  = timeadd(timestamp(), "-5m")
  expiry = timeadd(timestamp(), "${var.sas_expiry_hours}h")

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

locals {
  blob_url = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.c.name}/${azurerm_storage_blob.script.name}"
  sas_url  = "${local.blob_url}?${data.azurerm_storage_account_sas.blob_sas.sas}"
}
