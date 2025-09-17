#############################################
# Project / shared resources
#############################################

project_name          = "avdproj"
default_location      = "eastus"
shared_resource_group = "rg-avd-shared"

tags = {
  environment = "dev"
  owner       = "relops"
  project     = "avd-secure"
}

#############################################
# Bootstrap credentials
#############################################

admin_username = "avdadmin"
# admin_password is NOT stored here.
# Supply securely at runtime:
#   export TF_VAR_admin_password='Some$trongTempPass!'
#   terraform apply

#############################################
# IAM principals
#############################################

# Markco Test Group
principal_ids = [
  "b6f616f1-77b3-4337-b485-bf8ee0e5e934"
]

#############################################
# Monitoring alerts
#############################################

alert_emails = [
  "mcornmesser@mozilla.com",
  "relops2@mozilla.com"
]

#############################################
# Pools (per host pool)
#############################################

pools = {
  pool1 = {
    location            = "westus"
    resource_group_name = "rg-avd-westus"
    vnet_cidr           = "10.10.0.0/16"
    subnet_cidr         = "10.10.1.0/24"

    vm_count = 2
    # TEMP size for testing
    # need to eval once region is decided
    vm_size = "Standard_D8as_v6"

    # Marketplace image (Windows 11 multi-session + M365 apps)
    image = {
      publisher = "microsoftwindowsdesktop"
      offer     = "windows-11"
      sku       = "win11-24h2-avd"
      version   = "latest"
    }

    deploy_vms                     = true
    max_sessions_per_host          = 10
    registration_token_valid_hours = 1
    custom_rdp_properties          = "redirectclipboard:i:0;multimon:i:1"
    enable_laps_local              = true

  }
}
