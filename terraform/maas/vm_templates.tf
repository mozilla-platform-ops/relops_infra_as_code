data "vsphere_virtual_machine" "mdc1_template" {
  provider      = vsphere.mdc1
  name          = "ubuntu-1804-packer-template"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}

data "vsphere_virtual_machine" "mdc2_template" {
  provider      = vsphere.mdc2
  name          = "ubuntu-1804-packer-template"
  datacenter_id = data.vsphere_datacenter.mdc2.id
}

