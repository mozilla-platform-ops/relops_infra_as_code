locals {
  sp3_perf_dedicated_host_location = "West US 3"
  sp3_perf_dedicated_host_slug     = local.location_map[local.sp3_perf_dedicated_host_location]
  sp3_perf_dedicated_host_tags = merge(local.tags, {
    bugzilla       = "2039391"
    jira           = "RELOPS-2375"
    lifecycle      = "temporary-test"
    owner_email    = "jmoss@mozilla.com"
    purpose        = "speedometer3-dedicated-host-placement-test"
    ttl            = "destroy-after-experiment"
    worker_pool_id = "gecko-t/win11-64-25h2-gpu-perf-experiment"
  })
}

resource "azapi_resource" "sp3_perf_experiment_host_group" {
  type = "Microsoft.Compute/hostGroups@2023-09-01"
  name = "dhg-${local.sp3_perf_dedicated_host_slug}-${local.provisioner}-sp3-perf"
  # Use the existing gecko-t West US 3 resource group from main.tf
  parent_id = azurerm_resource_group.nongw[local.sp3_perf_dedicated_host_location].id
  location  = azurerm_resource_group.nongw[local.sp3_perf_dedicated_host_location].location
  tags      = local.sp3_perf_dedicated_host_tags

  body = {
    properties = {
      platformFaultDomainCount  = 1
      supportAutomaticPlacement = true
    }
  }
}

resource "azapi_resource" "sp3_perf_experiment_host" {
  type      = "Microsoft.Compute/hostGroups/hosts@2023-09-01"
  name      = "dh-${local.sp3_perf_dedicated_host_slug}-${local.provisioner}-sp3-perf-01"
  parent_id = azapi_resource.sp3_perf_experiment_host_group.id
  location  = azurerm_resource_group.nongw[local.sp3_perf_dedicated_host_location].location
  tags      = local.sp3_perf_dedicated_host_tags

  body = {
    sku = {
      name = "NVadsA10v5_Type1"
    }
    properties = {
      platformFaultDomain  = 0
      autoReplaceOnFailure = true
    }
  }
}

output "sp3_perf_dedicated_host_group_id" {
  description = "Dedicated Host Group ID for the RELOPS-2375 Speedometer 3 GPU perf experiment."
  value       = azapi_resource.sp3_perf_experiment_host_group.id
}

output "sp3_perf_dedicated_host_id" {
  description = "Dedicated Host ID for the RELOPS-2375 Speedometer 3 GPU perf experiment."
  value       = azapi_resource.sp3_perf_experiment_host.id
}

output "sp3_perf_dedicated_host_resource_group_name" {
  description = "Resource group containing the RELOPS-2375 Speedometer 3 dedicated host resources."
  value       = azurerm_resource_group.nongw[local.sp3_perf_dedicated_host_location].name
}
