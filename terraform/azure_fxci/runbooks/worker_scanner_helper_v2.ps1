# This is a helper script for worker-scanner
# The intent is to remove unattached resources from deleted VMs
# and reduce the the disparage in worker-manager poll capacities.

# Determines NICs that have a MAC address but aren't attached as old
# Determines disk with null value for managed by as old

$connection = Get-AutomationConnection -Name AzureRunAsConnection
$connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

$n = 0
$d = 0
$target_group = "rg-taskcluster-worker-manager-production"
$pip_prefix = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-taskcluster-worker-manager-production/providers/Microsoft.Network/publicIPAddresses/"
$old_nics = (Get-AzNetworkInterface | where-object { $_.VirtualMachine -eq $null })



write-output "Removing unattached NICs"
write-output "$null"
foreach ($nic in $old_nics) {
	if ((!($nic.MacAddress -like $null)) -and ($nic.ResourceGroupName -eq $target_group)) {
		$nic_object = Get-AzNetworkInterface -Name $nic.Name -ResourceGroupName $nic.ResourceGroupName
		$pIP = ($nic.IpConfigurations.PublicIpAddress.Id -replace $pip_prefix )

		write-output ('Removing NIC and configuration for {0}' -f $nic.Name)
		#write-output ('Will remove Public IP: {0}' -f $pIP)
		write-output "$null"
		##Remove-AzNetworkInterfaceIpConfig  -Name IPConfig-1 -NetworkInterface $nic_object
		##Remove-AzNetworkInterface -Name $nic.Name -ResourceGroup $nic.ResourceGroupName -force
		#Remove-AzPublicIpAddress -Name $pIP -ResourceGroup $nic.ResourceGroupName -force
		$n = ($n +1)
	}
}

write-output "Removing unattached disks"
write-output "$null"
$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
    if(($md.ManagedBy -eq $null) -and ($md.ResourceGroupName -eq "rg-taskcluster-worker-manager-production")) {
		write-output ('Deleting Disk with Id: {0}' -f $md.Id)
		write-output "$null"
		##$md | Remove-AzDisk -Force

		$d = ($d + 2)
    }
 }


write-output "Total number of NICs removed: $n"
write-output "Total number of disks (2 per VM) removed: $d"
