# RELOPS-2520 — the only RG the "Desktop Integrations VMs" group can build in.
# Role is in azure_ad/rbac_desktop_integrations.tf and scoped to this RG's ID, so
# apply this workspace first and update that file if the name changes.
resource "azurerm_resource_group" "rg-west-us-desktop-integrations" {
  name     = "rg-west-us-desktop-integrations"
  location = "West US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-desktop-integrations"
    })
  )
}
