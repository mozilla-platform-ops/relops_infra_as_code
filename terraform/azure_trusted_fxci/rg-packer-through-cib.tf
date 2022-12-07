resource "azurerm_resource_group" "rg-packer-through-cib" {
  name     = "rg-packer-through-cib"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-through-cib"
    })
  )
}
