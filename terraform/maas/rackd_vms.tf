# MAAS MDC1 rackd controller vm
resource "vsphere_virtual_machine" "mdc1_wintest_rackd_1" {
  provider = vsphere.mdc1

  name                 = "maas-rackd1.wintest.releng.mdc1.mozilla.com"
  resource_pool_id     = data.vsphere_resource_pool.mdc1_relops_terraform_resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.mdc1_releng_datastore_cluster.id

  annotation = "Managed by Terraform"
  num_cpus   = 2
  memory     = 4096
  guest_id   = data.vsphere_virtual_machine.mdc1_template.guest_id

  folder         = "Relops-Terraform"
  enable_logging = true

  scsi_type = "lsilogic"

  # wintest.relng.mdc1 vlan
  network_interface {
    network_id     = data.vsphere_network.mdc1_releng_network_vlan_240.id
    use_static_mac = true
    mac_address    = var.maas_mdc1_rackd_mac_address
  }

  disk {
    label            = "disk0"
    size             = 200
    keep_on_remove   = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.mdc1_template.id

    customize {
      network_interface {}
      linux_options {
        host_name = "maas-rackd1"
        domain    = "wintest.releng.mdc1.mozilla.com"
      }
    }
  }
}

output "mdc1_rackd_vms" {
  value = {
    "name"        = vsphere_virtual_machine.mdc1_wintest_rackd_1.name
    "mac_address" = vsphere_virtual_machine.mdc1_wintest_rackd_1.network_interface.0.mac_address
    "ip_address"  = vsphere_virtual_machine.mdc1_wintest_rackd_1.default_ip_address
  }
}

# MAAS MDC2 rackd controller vm
resource "vsphere_virtual_machine" "mdc2_wintest_rackd_1" {
  provider = vsphere.mdc2

  name                 = "maas-rackd1.wintest.releng.mdc2.mozilla.com"
  resource_pool_id     = data.vsphere_resource_pool.mdc2_relops_terraform_resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.mdc2_releng_datastore_cluster.id

  annotation = "Managed by Terraform"
  num_cpus   = 2
  memory     = 4096
  guest_id   = data.vsphere_virtual_machine.mdc2_template.guest_id

  folder         = "Relops-Terraform"
  enable_logging = true

  scsi_type = "lsilogic"

  # wintest.relng.mdc2 vlan
  network_interface {
    network_id     = data.vsphere_network.mdc2_releng_network_vlan_240.id
    use_static_mac = true
    mac_address    = var.maas_mdc2_rackd_mac_address
  }

  disk {
    label            = "disk0"
    size             = 200
    keep_on_remove   = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.mdc2_template.id

    customize {
      network_interface {}
      linux_options {
        host_name = "maas-rackd1"
        domain    = "wintest.releng.mdc2.mozilla.com"
      }
    }
  }
}

output "mdc2_rackd_vms" {
  value = {
    "name"        = vsphere_virtual_machine.mdc2_wintest_rackd_1.name
    "mac_address" = vsphere_virtual_machine.mdc2_wintest_rackd_1.network_interface.0.mac_address
    "ip_address"  = vsphere_virtual_machine.mdc2_wintest_rackd_1.default_ip_address
  }
}
