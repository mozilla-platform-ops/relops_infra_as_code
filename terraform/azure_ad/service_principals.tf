locals {
  # The service principal resource only accept a list of strings as tags
  # So we here we iterate over the map object, join the key and values
  # then cast it to a list
  sp_tags = [for k, v in local.common_tags : join(":", [k, v])]
}

# a reference to the current subscription
data "azurerm_subscription" "currentSubscription" {}
