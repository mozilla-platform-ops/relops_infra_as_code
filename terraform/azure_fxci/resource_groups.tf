resource "azurerm_resource_group" "relops_terraform" {
  name     = "relops_terraform"
  location = "West US"

  tags = merge(local.common_tags,
    map(
      "Name", "relops_terraform"
    )
  )
}
