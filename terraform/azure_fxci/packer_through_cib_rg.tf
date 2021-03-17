resource "azurerm_resource_group" "packer_through_cib-rg" {
  name     = "packer_through_cib_rg"
  location = "Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "packer_throuhgcib_rg"
    )
  )
}
