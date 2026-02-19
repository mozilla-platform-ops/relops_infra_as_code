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

locals {
  shared_images = {
    "trusted_win11_a64_25h2_builder" = {
      publisher          = "windows11preview-arm64"
      offer              = "Windows-11"
      sku                = "win11-25h2-ent"
      architecture       = "Arm64"
      os_type            = "Windows"
      hyper_v_generation = "V2"
    },
    "trusted_win11_64_25h2" = {
      publisher          = "MicrosoftWindowsDesktop"
      offer              = "Windows-11"
      sku                = "win11-25h2-avd"
      architecture       = "x64"
      os_type            = "Windows"
      hyper_v_generation = "V2"
    }
  }
}

resource "azurerm_shared_image_gallery" "this" {
  for_each            = local.shared_images
  name                = each.key
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = replace(each.key, "_", "-")

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "this" {
  for_each                          = local.shared_images
  name                              = each.key
  gallery_name                      = azurerm_shared_image_gallery.this[each.key].name
  resource_group_name               = azurerm_resource_group.rg-packer-worker-images.name
  location                          = azurerm_resource_group.rg-packer-worker-images.location
  os_type                           = each.value.os_type
  release_note_uri                  = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation                = each.value.hyper_v_generation
  architecture                      = each.value.architecture
  disk_controller_type_nvme_enabled = true

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )

  identifier {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
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
