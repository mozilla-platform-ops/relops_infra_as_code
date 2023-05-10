resource "azurerm_resource_group" "rg-packer-worker-images" {
  name     = "rg-packer-worker-images"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image_gallery" "packer" {
  name                = "workerimages"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "stores taskcluster worker images"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_2009" {
  name                = "win11-64-2009"
  gallery_name        = azurerm_shared_image_gallery.packer.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
  }
}

resource "azurerm_shared_image" "win10_64_2009" {
  name                = "win10-64-2009"
  gallery_name        = azurerm_shared_image_gallery.packer.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-avd"
  }
}