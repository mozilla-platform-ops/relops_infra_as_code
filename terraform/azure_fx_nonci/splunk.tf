resource "azurerm_resource_group" "splunkeventhub" {
  name     = "rg-splunk-eventhub"
  location = "East US 2"
  tags = merge(local.common_tags,
    tomap({
      "tag_owner_email" = "infrastructuresecurity@mozilla.com"
    })
  )
}

resource "azurerm_eventhub_namespace" "splunk" {
  name                 = "splunk-eventhub"
  location             = azurerm_resource_group.splunkeventhub.location
  resource_group_name  = azurerm_resource_group.splunkeventhub.name
  sku                  = "Standard"
  capacity             = 4
  auto_inflate_enabled = true

  tags = merge(local.common_tags,
    tomap({
      "tag_owner_email" = "infrastructuresecurity@mozilla.com"
    })
  )
}

resource "azurerm_eventhub" "entralogs" {
  name                = "entralogs"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunkeventhub.name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub" "activitylogs" {
  name                = "activitylogs"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunkeventhub.name
  partition_count     = 2
  message_retention   = 7
}
