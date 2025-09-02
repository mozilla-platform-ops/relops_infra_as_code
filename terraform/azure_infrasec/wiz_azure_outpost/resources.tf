/*
=================================================
WIZ RESOURCE GROUP FOR ORCHESTRATOR RESOURCES
=================================================
*/

# The resource group where we place the key vaults and Storage
resource "azurerm_resource_group" "wiz_orchestrator_rg" {
  name     = var.wiz_global_orchestrator_rg_name
  location = var.wiz_global_orchestrator_rg_region
  tags = {
    "wiz" = ""
  }
}

/*
=================================================
WIZ KEY VAULT FOR APP SECRETS
=================================================
*/

locals {
  wiz_da_worker_principal_id = var.use_worker_managed_identity ? azurerm_user_assigned_identity.wiz_da_worker_identity[0].principal_id : azuread_service_principal.wiz_da_worker_sp[0].object_id
}

# The key vault used by wiz to store app keys
resource "azurerm_key_vault" "wiz_outpost_keyvault" {
  name                            = var.wiz_application_keyvault_name
  location                        = azurerm_resource_group.wiz_orchestrator_rg.location
  resource_group_name             = azurerm_resource_group.wiz_orchestrator_rg.name
  tenant_id                       = var.azure_tenant_id
  enabled_for_disk_encryption     = false
  soft_delete_retention_days      = 90
  purge_protection_enabled        = false
  enable_rbac_authorization       = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  sku_name                        = "standard"

  # A policy for the entity calling the terraform to put keys/etc
  access_policy {
    tenant_id               = var.azure_tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
    secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
    certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
    storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
  }
  # Access for the Wiz Disk Analyzer - Orchestrator app
  access_policy {
    tenant_id          = var.azure_tenant_id
    object_id          = azuread_service_principal.wiz_da_orchestrator_sp.object_id
    key_permissions    = ["Update", "Create", "List", "Get", "Delete"]
    secret_permissions = ["Set", "List", "Get", "Delete"]
  }
  # Access for the Wiz Disk Analyzer - Worker app
  access_policy {
    tenant_id               = var.azure_tenant_id
    object_id               = local.wiz_da_worker_principal_id
    key_permissions         = ["Get", "List", "Sign"]
    secret_permissions      = ["Get", "List"]
    certificate_permissions = ["Get", "List"]
  }

  public_network_access_enabled = true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
  tags = {
    "wiz" = ""
  }
}

/*
=================================================
SECRET MANAGEMENT FOR WIZ KEY VAULTS
NOTE:
- These could be done in a for_each loop, however we maintain them separately
- This is done for readibility/ease of editing
=================================================
*/


# LOCAL CONDITIONAL VARIABLES
# NOTE:
# - if values == "wiz_auto_create_secret", then assign value left of : , else assign value right of :

# Allow for custom secret config for the Wiz Disk Analyzer - Scanner app
locals {
  wiz_da_scanner_pass = (var.wiz_da_scanner_app_secret == "wiz_auto_create_secret" ? azuread_application_password.wiz_da_scanner_pass.value : var.wiz_da_scanner_app_secret)
}

# Allow for custom secret config for the Wiz Disk Analyzer - Worker app
locals {
  wiz_da_worker_pass = (var.wiz_da_worker_app_secret == "wiz_auto_create_secret" && !var.use_worker_managed_identity ? azuread_application_password.wiz_da_worker_pass[0].value : var.wiz_da_worker_app_secret)
}

# Write the Wiz Disk Analyzer - Scanner app secret to the key vault
resource "azurerm_key_vault_secret" "wiz_da_scanner_secret" {
  name         = azuread_application.wiz_da_scanner.client_id
  value        = jsonencode({ "tenantId" = var.azure_tenant_id, "clientId" = azuread_application.wiz_da_scanner.client_id, "secretId" = local.wiz_da_scanner_pass })
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id
  tags = {
    "app-name" = var.wiz_da_scanner_app_name
    "file-encoding" : "utf-8"
  }
}

locals {
  create_scanner_app_key_vault_certificate = var.scanner_app_key_vault_certificate_pem_file_path == null
}

# Create/Import the Wiz Disk Analyzer - Scanner app certificate to the key vault
resource "azurerm_key_vault_certificate" "wiz_da_scanner_certificate" {
  name         = "${azuread_application.wiz_da_scanner.client_id}-certificate"
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id

  dynamic "certificate_policy" {
    for_each = local.create_scanner_app_key_vault_certificate ? [0] : []
    content {
      issuer_parameters {
        name = "Self"
      }
      x509_certificate_properties {
        subject            = "CN=${azuread_application.wiz_da_scanner.client_id}.wiz.io"
        key_usage          = ["cRLSign", "digitalSignature", "keyEncipherment", "keyAgreement", "keyCertSign"]
        validity_in_months = 12
      }
      key_properties {
        exportable = false
        key_type   = "RSA"
        reuse_key  = false
        key_size   = 4096
      }
      secret_properties {
        content_type = "application/x-pkcs12"
      }
    }
  }

  dynamic "certificate" {
    for_each = local.create_scanner_app_key_vault_certificate ? [] : [0]
    content {
      contents = file(var.scanner_app_key_vault_certificate_pem_file_path)
    }
  }

  depends_on = [
    azurerm_key_vault.wiz_outpost_keyvault,
  ]
}

resource "azuread_application_certificate" "wiz_da_scanner_certificate" {
  application_id = format("/applications/%s", azuread_application.wiz_da_scanner.object_id)
  type           = "AsymmetricX509Cert"
  value          = azurerm_key_vault_certificate.wiz_da_scanner_certificate.certificate_data_base64
  encoding       = "pem"
}

# Write the Wiz Disk Analyzer - Worker app secret to the key vault
resource "azurerm_key_vault_secret" "wiz_da_worker_secret" {
  count        = var.use_worker_managed_identity ? 0 : 1
  name         = azuread_application.wiz_da_worker[count.index].client_id
  key_vault_id = azurerm_key_vault.wiz_outpost_keyvault.id
  value        = jsonencode({ "tenantId" = var.azure_tenant_id, "clientId" = azuread_application.wiz_da_worker[count.index].client_id, "secretId" = local.wiz_da_worker_pass })
  tags = {
    "app-name" : var.wiz_da_worker_app_name
    "file-encoding" : "utf-8"
  }
}
