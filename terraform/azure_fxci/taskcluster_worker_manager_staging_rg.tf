resource "azurerm_resource_group" "taskcluster_worker_manager_staging_rg" {
  name     = "taskcluster_worker_manager_staging_rg"
  location = "Central US"
  tags = merge(local.common_tags,
    map(
      "Name", "taskcluster_worker_manager_staging_rg"
    )
  )
}
