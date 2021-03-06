resource "azurerm_resource_group" "rg-taskcluster-worker-manager-production" {
  name     = "rg-taskcluster-worker-manager-production"
  location = "Central US"
  tags = merge(local.common_tags,
    tomap({
      "Name" = "rg-taskcluster-worker-manager-production"
    })
  )
}
