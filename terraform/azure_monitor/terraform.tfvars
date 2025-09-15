# ===================================================================
# terraform.tfvars — Multi-region AVD (self-documenting)
# -------------------------------------------------------------------
# How to define a POOL entry:
#
# pools = {
#   <pool_key> = {
#     # 1) REQUIRED infra + VM settings
#     location     = "<azure-region>"        # e.g., "eastus", "westus2"
#     vnet_cidr    = "10.x.0.0/16"
#     subnet_cidr  = "10.x.1.0/24"
#     vm_count     = <number>                # e.g., 2
#     vm_size      = "<SKU>"                 # e.g., "Standard_D8s_v5"
#     deploy_vms   = true | false            # create session hosts or infra only
#
#     # 2) REQUIRED image block — choose ONE of the following patterns:
#
#     # 2a) Marketplace image (publisher/offer/sku/version)
#     image = {
#       source    = "marketplace"
#       publisher = "MicrosoftWindowsDesktop"
#       offer     = "windows-11"
#       sku       = "win11-24h2-avd"
#       version   = "26100.4946.250810"     # pin a version available in this region
#     }
#
#     # 2b) Shared Image Gallery (SIG) image
#     # image = {
#     #   source                   = "sig"
#     #   gallery_resource_group   = "rg-images"
#     #   gallery_name             = "moz-secure-gallery"
#     #   image_name               = "avd-secure"
#     #   image_version            = "1.0.4"         # SIG version (forces replace when changed)
#     # }
#
#     # 2c) Direct image ID (SIG version or managed image)
#     # image = {
#     #   source          = "id"
#     #   source_image_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/galleries/<gal>/images/<img>/versions/<ver>"
#     # }
#   }
# }
#
# Global notes:
# - DO NOT put secrets here. Inject admin_password via env: export TF_VAR_admin_password="..."
# - principal_ids are Entra ID (AAD) object IDs (users/groups) that get Desktop Virtualization User on the app group.
# - pool_key is used in naming (e.g., avd-secure-<pool_key>-agents-*).
# ===================================================================

# -------- Global settings --------
prefix         = "avd-secure"
admin_username = "avdadmin"

# Inject at runtime:
#   export TF_VAR_admin_password="$(openssl rand -base64 24)"

principal_ids = [
  "b6f616f1-77b3-4337-b485-bf8ee0e5e934" # Example: AVD Users group objectId
]

# -------- Pools (single test pool example) --------
pools = {
  test = {
    location    = "eastus2"
    vnet_cidr   = "10.90.0.0/16"
    subnet_cidr = "10.90.1.0/24"
    vm_count    = 1
    vm_size     = "Standard_D8s_v5"
    deploy_vms  = true

    # Marketplace image (Win11 24H2 AVD) — verify version exists in this region
    image = {
      source    = "marketplace"
      publisher = "MicrosoftWindowsDesktop"
      offer     = "windows-11"
      sku       = "win11-24h2-avd"
      version   = "26100.4946.250810"
    }

    # --- Alternative image patterns (commented) ---
    # image = {
    #   source                   = "sig"
    #   gallery_resource_group   = "rg-images"
    #   gallery_name             = "moz-secure-gallery"
    #   image_name               = "avd-secure"
    #   image_version            = "1.0.4"
    # }

    # image = {
    #   source          = "id"
    #   source_image_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-images/providers/Microsoft.Compute/galleries/moz-secure-gallery/images/avd-secure/versions/1.0.4"
    # }
  }
}
