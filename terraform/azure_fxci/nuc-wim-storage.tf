# =============================================================================
# Private (locked-down) Blob storage for NUC Windows install.wim files.
#
# Tier 1 privacy: the account keeps a public endpoint but network_rules default
# to Deny, so ONLY the allow-listed networks can reach it, and all access still
# requires auth (Entra RBAC or SAS). No anonymous/public blob access.
#   - Packer build VM  -> reaches it via the Microsoft.Storage service endpoint
#                          on the dedicated Packer subnet (below).
#   - On-site MDC1 srv  -> reaches it from its allow-listed egress IP(s).
#
# Containers:
#   base     - bring-your-own starting install.wim (uploaded once)
#   captured - baked golden install.wim output by the wim-packer pipeline
#
# Region Central US to co-locate with Packer / the image galleries.
# =============================================================================

variable "mdc1_egress_cidrs" {
  type        = list(string)
  description = "Public egress IP/CIDR(s) of the on-site MDC1 server(s) that download the captured WIM. Confirmed with netops 2026-07-23: 63.245.208.129 is the MDC1 egress used by the downloader host. NOTE: Azure storage firewall rejects /31 and /32 — specify a single host as a bare IP (no mask), or use a CIDR with prefix 0-30."
  default     = ["63.245.208.129"]
}

variable "nuc_wim_downloader_object_id" {
  type        = string
  description = "Entra object ID of the SP/managed identity the MDC1 server uses to download (from azure_ad/sp_nuc_wim_downloader.tf output, applied first). Empty = skip the RBAC grant (use SAS instead)."
  # sp-relops-nuc-wim-downloader (azure_ad/sp_nuc_wim_downloader.tf), applied 2026-07-23.
  default = "ae54832f-8931-46d8-8faa-133637e72798"
}

resource "azurerm_resource_group" "nuc-wim" {
  name     = "rg-${local.locationshort}-nuc-wim"
  location = local.location
  tags     = merge(local.common_tags, tomap({ "Name" = "rg-${local.locationshort}-nuc-wim" }))
}

# Dedicated VNet + subnet for Packer builds, with the Storage service endpoint so
# the build VM's traffic is allowed by the storage firewall (no private endpoint).
resource "azurerm_virtual_network" "nuc-wim" {
  name                = "vn-${local.locationshort}-nuc-wim"
  location            = azurerm_resource_group.nuc-wim.location
  resource_group_name = azurerm_resource_group.nuc-wim.name
  address_space       = ["10.20.0.0/24"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "nuc-wim-packer" {
  name                 = "sn-${local.locationshort}-nuc-wim-packer"
  resource_group_name  = azurerm_resource_group.nuc-wim.name
  virtual_network_name = azurerm_virtual_network.nuc-wim.name
  address_prefixes     = ["10.20.0.0/26"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "nuc-wim" {
  name                     = "nucwimfxci"
  resource_group_name      = azurerm_resource_group.nuc-wim.name
  location                 = azurerm_resource_group.nuc-wim.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Tier-1 privacy posture: public endpoint stays, but no anonymous access and
  # deny-by-default firewall. Auth is always required.
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = true # keep true so a read-only SAS is possible for MDC1

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.mdc1_egress_cidrs
    virtual_network_subnet_ids = [azurerm_subnet.nuc-wim-packer.id]
  }

  tags = merge(local.common_tags, tomap({ "Name" = "nucwimfxci" }))
}

resource "azurerm_storage_container" "base" {
  name                  = "base"
  storage_account_id    = azurerm_storage_account.nuc-wim.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "captured" {
  name                  = "captured"
  storage_account_id    = azurerm_storage_account.nuc-wim.id
  container_access_type = "private"
}

# --- Data-plane RBAC (Entra auth; preferred over keys/SAS) ---------------------
# Packer (worker_images SP, object id from keyvault.tf locals) reads base + writes
# captured -> Storage Blob Data Contributor.
resource "azurerm_role_assignment" "packer_wim_rw" {
  scope                = azurerm_storage_account.nuc-wim.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.worker_images_object_id
}

# MDC1 downloader (if using Entra auth) reads captured -> Storage Blob Data Reader.
# Scoped to the 'captured' container only. Skipped when object id is empty (SAS path).
resource "azurerm_role_assignment" "mdc1_wim_ro" {
  count                = var.nuc_wim_downloader_object_id == "" ? 0 : 1
  scope                = azurerm_storage_container.captured.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.nuc_wim_downloader_object_id
}

output "nuc_wim_storage_account" {
  value = azurerm_storage_account.nuc-wim.name
}
output "nuc_wim_packer_subnet_id" {
  value = azurerm_subnet.nuc-wim-packer.id
}
