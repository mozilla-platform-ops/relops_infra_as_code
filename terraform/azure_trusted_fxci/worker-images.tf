resource "azurerm_resource_group" "rg-packer-worker-images" {
  name     = "rg-packer-worker-images"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image_gallery" "trusted_win11_a64_24h2_builder" {
  name                = "trusted_win11_a64_24h2_builder"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "trusted-win11-a64-24h2-builder"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "trusted_win11_a64_24h2_builder" {
  name                = "trusted_win11_a64_24h2_builder"
  gallery_name        = azurerm_shared_image_gallery.trusted_win11_a64_24h2_builder.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"
  architecture        = "Arm64"

  identifier {
    publisher = "windows11preview-arm64"
    offer     = "Windows-11"
    sku       = "win11-24h2-ent"
  }
}

resource "azurerm_shared_image_gallery" "trusted_win2022_64_2009" {
  name                = "trusted_win2022_64_2009"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "trusted-win2022-64-2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "trusted_win2022_64_2009" {
  name                = "trusted_win2022_64_2009"
  gallery_name        = azurerm_shared_image_gallery.trusted_win2022_64_2009.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
  }
}