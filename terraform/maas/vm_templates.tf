data "vsphere_virtual_machine" "mdc1_template" {
  provider      = vsphere.mdc1
  name          = "ubuntu-1804-packer-template-2020-05-05T16:56:52Z"
  datacenter_id = data.vsphere_datacenter.mdc1.id
}


