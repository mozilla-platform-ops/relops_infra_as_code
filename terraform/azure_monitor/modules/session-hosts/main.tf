# ------------------------------------------------------------
# Locals
# ------------------------------------------------------------
locals {
  # Computer name base: strip dashes, limit to 12 chars; append 3-digit index => max 15 chars
  comp_base    = substr(replace(var.name, "-", ""), 0, 12)

  # Whether to include LAPS script in bootstrap
  laps_enabled = var.enable_laps && !var.laps_managed_by_intune

  # Inline PowerShell for LAPS local config (only used if laps_enabled)
  laps_script = <<-EOLAPS
    $root = 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\LAPS\\Config'
    if (-not (Test-Path $root)) { New-Item -Path $root -Force | Out-Null }

    $BackupDirectory    = ${var.laps_backup_directory}
    $PasswordAgeDays    = ${var.laps_password_age_days}
    $PasswordLength     = ${var.laps_password_length}
    $PasswordComplexity = ${var.laps_password_complexity}
    $AdminName          = "${var.laps_admin_account_name != null ? var.laps_admin_account_name : ""}"

    New-ItemProperty -Path $root -Name BackupDirectory    -Value $BackupDirectory    -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $root -Name PasswordAgeDays    -Value $PasswordAgeDays    -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $root -Name PasswordLength     -Value $PasswordLength     -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $root -Name PasswordComplexity -Value $PasswordComplexity -PropertyType DWord -Force | Out-Null

    if ($AdminName -ne "") {
      New-ItemProperty -Path $root -Name AdministratorAccountName -Value $AdminName -PropertyType String -Force | Out-Null
    }

    try {
      Import-Module LAPS -ErrorAction Stop
      Invoke-LapsPolicyProcessing
    } catch {
      # If LAPS module isn’t ready, Windows will process on its next cycle
    }
  EOLAPS

  # Base64 for init (provided by module input) and LAPS
  init_b64 = var.init_script_b64
  laps_b64 = base64encode(local.laps_script)

  # Build the commandToExecute (two variants), executing scripts from memory.
  bootstrap_cmd_with_laps = join(" ; ", [
    # Run session-init from base64 (single-quoted literal for safety)
    "powershell -NoProfile -ExecutionPolicy Bypass -Command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.init_b64}')) | Invoke-Expression\"",
    # Run LAPS script from base64
    "powershell -NoProfile -ExecutionPolicy Bypass -Command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.laps_b64}')) | Invoke-Expression\""
  ])

  bootstrap_cmd_no_laps = join(" ; ", [
    "powershell -NoProfile -ExecutionPolicy Bypass -Command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.init_b64}')) | Invoke-Expression\""
  ])

  bootstrap_cmd = local.laps_enabled ? local.bootstrap_cmd_with_laps : local.bootstrap_cmd_no_laps
}

# ------------------------------------------------------------
# NICs
# ------------------------------------------------------------
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.name}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ------------------------------------------------------------
# Session host VMs
# ------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "${var.name}-sh-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  provision_vm_agent    = true
  license_type          = "Windows_Client"

  # <= 15 chars
  computer_name = format("%s%03d", local.comp_base, count.index)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Marketplace Win11 AVD
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-avd"
    version   = coalesce(var.image_version, "latest")
  }
}

# ------------------------------------------------------------
# Entra ID login extension
# ------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.vm_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# ------------------------------------------------------------
# Single bootstrap extension: execute init (and LAPS if enabled) in-memory
# ------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "bootstrap" {
  count                = var.vm_count
  name                 = "avd-bootstrap"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "cmd /c ${local.bootstrap_cmd}"
  })
}

# ------------------------------------------------------------
# Outputs
# ------------------------------------------------------------
output "vm_ids" {
  description = "IDs of the session host VMs"
  value       = [for v in azurerm_windows_virtual_machine.vm : v.id]
}
