resource "azurerm_resource_group" "rg-packer-worker-images" {
  name     = "rg-packer-worker-images"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

## win10-64-2009-alpha
resource "azurerm_shared_image_gallery" "win10_64_2009_alpha" {
  name                = "ronin_t_windows10_64_2009_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win10-64-2009-alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

## win10-64-2009
resource "azurerm_shared_image_gallery" "win10_64_2009" {
  name                = "ronin_t_windows10_64_2009_prod"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win10-64-2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win10_64_2009" {
  name                = "win10-64-2009"
  gallery_name        = azurerm_shared_image_gallery.win10_64_2009.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-avd"
  }
}

## win11-64-2009-alpha
resource "azurerm_shared_image_gallery" "win11_64_2009_alpha" {
  name                = "ronin_t_windows11_64_2009_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-64-2009-alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_2009_alpha" {
  name                = "win11-64-2009-alpha"
  gallery_name        = azurerm_shared_image_gallery.win11_64_2009_alpha.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
  }
}

## win11-64-2009
resource "azurerm_shared_image_gallery" "win11_64_2009" {
  name                = "ronin_t_windows11_64_2009_prod"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-64-2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_2009" {
  name                = "win11-64-2009"
  gallery_name        = azurerm_shared_image_gallery.win11_64_2009.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
  }
}
