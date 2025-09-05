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

data "azurerm_platform_image" "win11_avd" {
  location  = var.location
  publisher = "MicrosoftWindowsDesktop"
  offer     = "windows-11"
  sku       = "win11-23h2-avd"
  version   = "latest"
}

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

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.win11_avd.publisher
    offer     = data.azurerm_platform_image.win11_avd.offer
    sku       = data.azurerm_platform_image.win11_avd.sku
    version   = data.azurerm_platform_image.win11_avd.version
  }
}

# Run init script (AVD agent + stateless profile hygiene)
resource "azurerm_virtual_machine_extension" "init" {
  count                = var.vm_count
  name                 = "avd-init"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Bypass -Command \"$s=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${var.init_script_b64}')); Set-Content -Path C:\\Windows\\Temp\\init.ps1 -Value $s; powershell -ExecutionPolicy Bypass -File C:\\Windows\\Temp\\init.ps1\""
  })
}

# Enable Entra ID login
resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.vm_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

# Windows LAPS (no-Intune path)
resource "azurerm_virtual_machine_extension" "laps_local_config" {
  count                = var.enable_laps && !var.laps_managed_by_intune ? var.vm_count : 0
  name                 = "LAPS-Local-Config"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Bypass -File C:\\Windows\\Temp\\laps-local.ps1"
  })

  settings = jsonencode({
    fileUris = []
    script   = base64encode(<<-EOF
      $root = 'HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\LAPS\\Config'
      if (-not (Test-Path $root)) { New-Item -Path $root -Force | Out-Null }

      $BackupDirectory    = ${var.laps_backup_directory}
      $PasswordAgeDays    = ${var.laps_password_age_days}
      $PasswordLength     = ${var.laps_password_length}
      $PasswordComplexity = ${var.laps_password_complexity}
      $AdminName          = "${coalesce(var.laps_admin_account_name, "")}"

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
        # If LAPS module isn’t ready, Windows will process on its schedule
      }
    EOF
    )
  })
}

output "vm_ids" {
  value = [for v in azurerm_windows_virtual_machine.vm : v.id]
}