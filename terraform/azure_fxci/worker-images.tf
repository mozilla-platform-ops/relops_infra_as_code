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
  name                = "win10_64_2009_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win10_64_2009_alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win10_64_2009_alpha" {
  name                = "win10_64_2009_alpha"
  gallery_name        = azurerm_shared_image_gallery.win10_64_2009_alpha.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-avd-g2"
  }
}

## win10-64-2009
resource "azurerm_shared_image_gallery" "win10_64_2009" {
  name                = "win10_64_2009"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win10_64_2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win10_64_2009" {
  name                = "win10_64_2009"
  gallery_name        = azurerm_shared_image_gallery.win10_64_2009.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-avd-g2"
  }
}

## win11-64-2009-alpha
resource "azurerm_shared_image_gallery" "win11_64_2009_alpha" {
  name                = "win11_64_2009_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11_64_2009_alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_2009_alpha" {
  name                = "win11_64_2009_alpha"
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
  name                = "win11_64_2009"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11_64_2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_2009" {
  name                = "win11_64_2009"
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
## win11-a64-24h2-builder
resource "azurerm_shared_image_gallery" "win11_a64_24h2_builder_alpha" {
  name                = "win11_a64_24h2_builder_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-a64-24h2-builder-alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_a64_24h2_builder_alpha" {
  name                = "win11_a64_24h2_builder_alpha"
  gallery_name        = azurerm_shared_image_gallery.win11_a64_24h2_builder_alpha.name
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

resource "azurerm_shared_image_gallery" "win11_a64_24h2_builder" {
  name                = "win11_a64_24h2_builder"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-a64-24h2-builder"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_a64_24h2_builder" {
  name                = "win11_a64_24h2_builder"
  gallery_name        = azurerm_shared_image_gallery.win11_a64_24h2_builder.name
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


## win11-a64-24h2-tester
resource "azurerm_shared_image_gallery" "win11_a64_24h2_tester_alpha" {
  name                = "win11_a64_24h2_tester_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-a64-24h2-tester-alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_a64_24h2_tester_alpha" {
  name                = "win11_a64_24h2_tester_alpha"
  gallery_name        = azurerm_shared_image_gallery.win11_a64_24h2_tester_alpha.name
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

resource "azurerm_shared_image_gallery" "win11_a64_24h2_tester" {
  name                = "win11_a64_24h2_tester"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-a64-24h2-tester"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_a64_24h2_tester" {
  name                = "win11_a64_24h2_tester"
  gallery_name        = azurerm_shared_image_gallery.win11_a64_24h2_tester.name
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

resource "azurerm_shared_image_gallery" "win11_64_24h2" {
  name                = "win11_64_24h2"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-64-24h2"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_24h2" {
  name                = "win11_64_24h2"
  gallery_name        = azurerm_shared_image_gallery.win11_64_24h2.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-24h2-avd"
  }
}

resource "azurerm_shared_image_gallery" "win11_64_24h2_alpha" {
  name                = "win11_64_24h2_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win11-64-24h2-alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win11_64_24h2_alpha" {
  name                = "win11_64_24h2_alpha"
  gallery_name        = azurerm_shared_image_gallery.win11_64_24h2_alpha.name
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  os_type             = "Windows"
  release_note_uri    = "https://github.com/mozilla-platform-ops/worker-images/releases"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-24h2-avd"
  }
}

resource "azurerm_shared_image_gallery" "win2022_64_2009_alpha" {
  name                = "win2022_64_2009_alpha"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win2022_64_2009_alpha"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win2022_64_2009_alpha" {
  name                = "win2022_64_2009_alpha"
  gallery_name        = azurerm_shared_image_gallery.win2022_64_2009_alpha.name
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

resource "azurerm_shared_image_gallery" "win2022_64_2009" {
  name                = "win2022_64_2009"
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = "win2022_64_2009"

  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

resource "azurerm_shared_image" "win2022_64_2009" {
  name                = "win2022_64_2009"
  gallery_name        = azurerm_shared_image_gallery.win2022_64_2009.name
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