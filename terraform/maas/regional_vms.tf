# MAAS MDC1 regional controller vm
resource "vsphere_virtual_machine" "mdc1_regional_1" {
  provider = vsphere.mdc1

  name                 = "maas-regional1.srv.releng.mdc1.mozilla.com"
  resource_pool_id     = data.vsphere_resource_pool.mdc1_relops_terraform_resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.mdc1_releng_datastore_cluster.id

  annotation = "Managed by Terraform"
  num_cpus   = 2
  memory     = 4096
  guest_id   = "ubuntu64Guest"

  folder         = "Relops-Terraform"
  enable_logging = true

  scsi_type = "lsilogic"

  # srv.relng.mdc1 vlan
  network_interface {
    network_id = data.vsphere_network.mdc1_releng_network_vlan_248.id
  }

  disk {
    label          = "disk0"
    size           = 40
    keep_on_remove = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.mdc1_template.id

    customize {
      network_interface {}
      linux_options {
        host_name = "maas-regional1"
        domain    = "srv.releng.mdc1.mozilla.com"
      }
    }
  }
}

output "mdc1_regional_1_mac_address" {
  value = vsphere_virtual_machine.mdc1_regional_1.network_interface.0.mac_address
}

# MAAS MDC2 regional controller vm
resource "vsphere_virtual_machine" "mdc2_regional_1" {
  provider = vsphere.mdc2

  name                 = "maas-regional1.srv.releng.mdc2.mozilla.com"
  resource_pool_id     = data.vsphere_resource_pool.mdc2_relops_terraform_resource_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.mdc2_releng_datastore_cluster.id

  annotation = "Managed by Terraform"
  num_cpus   = 2
  memory     = 4096
  guest_id   = "ubuntu64Guest"

  folder         = "Relops-Terraform"
  enable_logging = true

  scsi_type = "lsilogic"

  # srv.relng.mdc2 vlan
  network_interface {
    network_id = data.vsphere_network.mdc2_releng_network_vlan_248.id
  }

  disk {
    label          = "disk0"
    size           = 40
    keep_on_remove = false
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.mdc2_template.id

    customize {
      network_interface {}
      linux_options {
        host_name = "maas-regional1"
        domain    = "srv.releng.mdc2.mozilla.com"
      }
    }
  }
}

output "mdc2_regional_1_mdc2_mac_address" {
  value = vsphere_virtual_machine.mdc2_regional_1.network_interface.0.mac_address
}
