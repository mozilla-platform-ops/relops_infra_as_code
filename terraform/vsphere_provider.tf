provider "vsphere" {
  alias                = "mdc1"
  vsphere_server       = "vc1.ops.mdc1.mozilla.com"
  allow_unverified_ssl = true
}

# ============================================================

# MDC1 Datacenter
data "vsphere_datacenter" "mdc1" {
  provider = vsphere.mdc1
  name     = "MDC1"
}

# MDC1 Releng RDS datastore cluster
data "vsphere_datastore_cluster" "mdc1_releng_datastore_cluster" {
  provider      = vsphere.mdc1
  name          = "esx_ssd_releng"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# MDC1 Relops-Terraform resource pool
data "vsphere_resource_pool" "mdc1_relops_terraform_resource_pool" {
  provider      = vsphere.mdc1
  name          = "Relops-Terraform"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# private.releng.mdc1 vlan275
data "vsphere_network" "mdc1_releng_network_vlan_275" {
  provider      = vsphere.mdc1
  name          = "RelEng Private VLAN275"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# public.releng.mdc1 vlan3001
data "vsphere_network" "mdc1_releng_network_vlan_3001" {
  provider      = vsphere.mdc1
  name          = "RelEng Public VLAN3001"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# relabs.releng.mdc1 vlan278
data "vsphere_network" "mdc1_releng_network_vlan_278" {
  provider      = vsphere.mdc1
  name          = "RelEng RELabs VLAN278"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# srv.releng.mdc1 vlan248
data "vsphere_network" "mdc1_releng_network_vlan_248" {
  provider      = vsphere.mdc1
  name          = "RelEng Srv VLAN248"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# test.releng.mcd1 vlan256
data "vsphere_network" "mdc1_releng_network_vlan_256" {
  provider      = vsphere.mdc1
  name          = "RelEng Test VLAN256"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# tier3.releng.mdc1 vlan260
data "vsphere_network" "mdc1_releng_network_vlan_260" {
  provider      = vsphere.mdc1
  name          = "RelEng Tier3 VLAN260"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

# wintest.releng.mdc1 vlan240
data "vsphere_network" "mdc1_releng_network_vlan_240" {
  provider      = vsphere.mdc1
  name          = "RelEng WinTest VLAN240"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

output "vsphere_mdc1" {
  value = {
    "datacenter_id"        = data.vsphere_datacenter.mdc1.id
    "datastore_cluster_id" = data.vsphere_datastore_cluster.mdc1_releng_datastore_cluster.id
    "resource_pool_id"     = data.vsphere_resource_pool.mdc1_relops_terraform_resource_pool.id
    "networks" = {
      "vlan_275" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_275.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_275.name
      }
      "vlan_3001" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_3001.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_3001.name
      }
      "vlan_278" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_278.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_278.name
      }
      "vlan_246" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_248.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_248.name
      }
      "vlan_256" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_256.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_256.name
      }
      "vlan_260" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_260.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_260.name
      }
      "vlan_240" = {
        "id"   = data.vsphere_network.mdc1_releng_network_vlan_240.id
        "name" = data.vsphere_network.mdc1_releng_network_vlan_240.name
      }
    }
  }
}


