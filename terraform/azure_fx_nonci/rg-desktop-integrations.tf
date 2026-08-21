# RELOPS-2520 — on-demand test VMs for the Desktop Integrations team.
#
# DI validate patches and reproduce bugs across operating systems, so they need
# to create and destroy short-lived VMs themselves. This resource group is the
# only place the "Desktop Integrations VMs" group can create anything; the
# custom role backing it is defined in the azure_ad workspace
# (rbac_desktop_integrations.tf) and is scoped to this RG's resource ID.
#
# Renaming this RG requires updating the constructed ID in that file, and this
# workspace must be applied before azure_ad — a role definition cannot be
# scoped to a resource group that does not exist yet.
resource "azurerm_resource_group" "rg-west-us-desktop-integrations" {
  name     = "rg-west-us-desktop-integrations"
  location = "West US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-west-us-desktop-integrations"
    })
  )
}
