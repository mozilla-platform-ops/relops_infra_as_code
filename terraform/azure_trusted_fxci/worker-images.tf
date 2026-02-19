resource "azurerm_resource_group" "rg-packer-worker-images" {
  name     = "rg-packer-worker-images"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )
}

locals {
  worker_image_tags = {
    terraform        = "true"
    project_name     = "worker-images"
    production_state = "production"
    owner_email      = "relops@mozilla.com"
    source_repo_url  = "https://github.com/mozilla-platform-ops/relops_infra_as_code"
  }
  legacy_gallery_tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-packer-worker-images"
    })
  )

  shared_images = {
    "trusted_win11_a64_24h2_builder" = {
      publisher                         = "windows11preview-arm64"
      offer                             = "Windows-11"
      sku                               = "win11-24h2-ent"
      architecture                      = "Arm64"
      os_type                           = "Windows"
      hyper_v_generation                = "V2"
      gallery_description               = "trusted-win11-a64-24h2-builder"
      gallery_tags                      = local.legacy_gallery_tags
      image_tags                        = {}
      disk_controller_type_nvme_enabled = false
    },
    "trusted_win11_a64_25h2_builder" = {
      publisher                         = "windows11preview-arm64"
      offer                             = "Windows-11"
      sku                               = "win11-25h2-ent"
      architecture                      = "Arm64"
      os_type                           = "Windows"
      hyper_v_generation                = "V2"
      gallery_description               = "Shared Image Gallery for win11-25h2-ent"
      gallery_tags                      = local.worker_image_tags
      image_tags                        = local.worker_image_tags
      disk_controller_type_nvme_enabled = true
    },
    "trusted_win11_64_25h2" = {
      publisher                         = "MicrosoftWindowsDesktop"
      offer                             = "Windows-11"
      sku                               = "win11-25h2-avd"
      architecture                      = "x64"
      os_type                           = "Windows"
      hyper_v_generation                = "V2"
      gallery_description               = "Shared Image Gallery for win11-25h2-avd"
      gallery_tags                      = local.worker_image_tags
      image_tags                        = local.worker_image_tags
      disk_controller_type_nvme_enabled = true
    },
    "trusted_win2022_64_2009" = {
      publisher                         = "MicrosoftWindowsServer"
      offer                             = "WindowsServer"
      sku                               = "2022-datacenter-azure-edition"
      architecture                      = "x64"
      os_type                           = "Windows"
      hyper_v_generation                = "V2"
      gallery_description               = "trusted-win2022-64-2009"
      gallery_tags                      = local.legacy_gallery_tags
      image_tags                        = {}
      disk_controller_type_nvme_enabled = false
    }
  }
}

moved {
  from = azurerm_shared_image_gallery.trusted_win11_a64_24h2_builder
  to   = azurerm_shared_image_gallery.this["trusted_win11_a64_24h2_builder"]
}

moved {
  from = azurerm_shared_image.trusted_win11_a64_24h2_builder
  to   = azurerm_shared_image.this["trusted_win11_a64_24h2_builder"]
}

moved {
  from = azurerm_shared_image_gallery.trusted_win2022_64_2009
  to   = azurerm_shared_image_gallery.this["trusted_win2022_64_2009"]
}

moved {
  from = azurerm_shared_image.trusted_win2022_64_2009
  to   = azurerm_shared_image.this["trusted_win2022_64_2009"]
}

resource "azurerm_shared_image_gallery" "this" {
  for_each            = local.shared_images
  name                = each.key
  resource_group_name = azurerm_resource_group.rg-packer-worker-images.name
  location            = azurerm_resource_group.rg-packer-worker-images.location
  description         = each.value.gallery_description
  tags                = each.value.gallery_tags
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
  disk_controller_type_nvme_enabled = each.value.disk_controller_type_nvme_enabled
  tags                              = length(each.value.image_tags) == 0 ? null : each.value.image_tags

  identifier {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
  }
}
