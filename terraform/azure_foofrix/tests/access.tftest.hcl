# Run with: terraform -chdir=terraform/azure_foofrix test
# Mock providers keep this access check offline.
mock_provider "azuread" {}
mock_provider "azurerm" {}
mock_provider "azurerm" {
  alias = "billing"
}

override_resource {
  target          = azurerm_resource_group.image_build
  override_during = plan
  values          = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-foofrix-image-build" }
}

override_resource {
  target          = azurerm_shared_image_gallery.foofrix
  override_during = plan
  values          = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-foofrix/providers/Microsoft.Compute/galleries/foofrix" }
}

override_resource {
  target          = azurerm_shared_image_gallery.windows_25h2
  override_during = plan
  values          = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-foofrix/providers/Microsoft.Compute/galleries/win11_64_25h2" }
}

override_resource {
  target          = azurerm_user_assigned_identity.image_build
  override_during = plan
  values          = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-foofrix/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-foofrix-image-build" }
}

override_resource {
  target          = azurerm_storage_container.artifacts
  override_during = plan
  values          = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-foofrix/providers/Microsoft.Storage/storageAccounts/safoofrix/blobServices/default/containers/artifacts" }
}

run "build_and_team_access" {
  command = plan

  assert {
    condition = (
      length(azurerm_role_assignment.image_build_contributor) == 3 &&
      azurerm_role_assignment.image_build_contributor["build"].scope == azurerm_resource_group.image_build.id &&
      azurerm_role_assignment.image_build_contributor["gallery"].scope == azurerm_shared_image_gallery.foofrix.id &&
      azurerm_role_assignment.image_build_contributor["gallery_25h2"].scope == azurerm_shared_image_gallery.windows_25h2.id &&
      azurerm_shared_image.windows_25h2.disk_controller_type_nvme_enabled &&
      azurerm_role_assignment.image_build_identity_operator.scope == azurerm_user_assigned_identity.image_build.id &&
      alltrue([for grant in azurerm_role_assignment.image_build_blob_reader : grant.scope == azurerm_storage_container.artifacts.id]) &&
      alltrue([for grant in azurerm_role_assignment.image_build_contributor : grant.role_definition_name == "Contributor"]) &&
      alltrue([for grant in azurerm_role_assignment.image_build_blob_reader : grant.role_definition_name == "Storage Blob Data Reader"]) &&
      length(azurerm_role_assignment.image_build_blob_reader) == 2 &&
      azurerm_role_assignment.image_build_identity_operator.role_definition_name == "Managed Identity Operator"
    )
    error_message = "The builder needs three Contributor grants, identity attachment, and read access for both build identities."
  }

  assert {
    condition = (
      azurerm_role_assignment.platform_performance_contributor.role_definition_name == "Contributor" &&
      azurerm_role_assignment.blob_contributor["platform_performance"].role_definition_name == "Storage Blob Data Contributor" &&
      azurerm_role_assignment.platform_performance_secrets_officer.role_definition_name == "Key Vault Secrets Officer"
    )
    error_message = "Platform Performance needs subscription, artifact, and secret access."
  }
}
