output "mdc1_regional_1_mdc1_mac_address" {
  value = vsphere_virtual_machine.mdc1_wintest_rackd_1.network_interface.0.mac_address
}

output "mdc2_regional_1_mdc2_mac_address" {
  value = vsphere_virtual_machine.mdc2_wintest_rackd_1.network_interface.0.mac_address
}
