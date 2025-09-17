#############################################
# Pull tenant/subscription from current provider
#############################################
data "azurerm_client_config" "current" {}

#############################################
# Locals
#############################################

locals {
  indices   = toset([for i in range(var.vm_count) : format("%03d", i)])
  base_name = substr(var.computer_name_prefix, 0, 11)
}

#############################################
# NICs (no public IPs)
#############################################

resource "azurerm_network_interface" "nic" {
  for_each            = local.indices
  name                = "${var.name}-nic-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

#############################################
# Windows Session Host VMs
#############################################

resource "azurerm_windows_virtual_machine" "vm" {
  for_each                   = local.indices
  name                       = format("%s-%s", local.base_name, each.key) # <= 15 chars
  location                   = var.location
  resource_group_name        = var.resource_group_name
  size                       = var.vm_size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  network_interface_ids      = [azurerm_network_interface.nic[each.key].id]
  provision_vm_agent         = true
  allow_extension_operations = true

  # Required for AADLoginForWindows to complete Azure AD join
  identity {
    type = "SystemAssigned"
  }

  # Image: Marketplace or SIG (mutually exclusive)
  dynamic "source_image_reference" {
    for_each = var.image != null ? [1] : []
    content {
      publisher = var.image.publisher
      offer     = var.image.offer
      sku       = var.image.sku
      version   = var.image.version
    }
  }

  source_image_id = var.sig_image != null ? var.sig_image.image_id : null

  os_disk {
    name                 = "${var.name}-osdisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = var.tags
}

#############################################
# AAD Login Extension (requires mdmId; pass tenantId too)
#############################################

resource "azurerm_virtual_machine_extension" "aad_login" {
  for_each             = var.enable_aad_login ? local.indices : toset([])
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

  # Some tenants require tenantId + mdmId for AAD join via the extension.
  settings = jsonencode({
    mdmId    = "0000000a-0000-0000-c000-000000000000"
    tenantId = data.azurerm_client_config.current.tenant_id
  })

  tags = var.tags
}

#############################################
# Bootstrap: Custom Script Extension
#############################################

resource "azurerm_virtual_machine_extension" "init" {
  for_each             = local.indices
  name                 = "avd-session-init"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [var.init_script_uri]
  })

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Bypass -File avd-session-init.ps1 -EnableLaps:${var.enable_laps_local} -HostPoolId:'${var.hostpool_id}' -RegistrationToken:'${var.registration_token}'"
  })

  tags = var.tags

  lifecycle {
    precondition {
      condition     = try(trimspace(nonsensitive(var.init_script_uri)) != "", false)
      error_message = "init_script_uri must be a non-empty URI when deploying session hosts."
    }
  }
}

#############################################
# DCR Association (per-VM)
#############################################

resource "azurerm_monitor_data_collection_rule_association" "vm" {
  for_each = var.enable_dcr_association ? local.indices : toset([])

  name                    = "dcr-avd-${var.name}-${each.key}"
  target_resource_id      = azurerm_windows_virtual_machine.vm[each.key].id
  data_collection_rule_id = var.dcr_id

  lifecycle {
    precondition {
      condition     = try(var.enable_dcr_association ? (length(nonsensitive(var.dcr_id)) > 0) : true, false)
      error_message = "dcr_id must be provided when enable_dcr_association is true."
    }
  }
}
