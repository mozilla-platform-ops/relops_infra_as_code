output "vm_ids" {
  description = "IDs of the session host VMs."
  value       = [for _, v in azurerm_windows_virtual_machine.vm : v.id]
}

output "vm_names" {
  description = "Names of the session host VMs."
  value       = [for _, v in azurerm_windows_virtual_machine.vm : v.name]
}
