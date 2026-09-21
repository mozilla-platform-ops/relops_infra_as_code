# Keep the existing galleries and image definitions when their addresses change.

moved {
  from = azurerm_shared_image_gallery.foofrix
  to   = azurerm_shared_image_gallery.this["win11_64_24h2"]
}

moved {
  from = azurerm_shared_image_gallery.windows_25h2
  to   = azurerm_shared_image_gallery.this["win11_64_25h2"]
}

moved {
  from = azurerm_shared_image.windows_25h2
  to   = azurerm_shared_image.this["win11_64_25h2"]
}

moved {
  from = azurerm_shared_image.windows
  to   = azurerm_shared_image.this["win11_64_24h2"]
}
