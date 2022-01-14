# Cleanup unattached resources in rg-north-central-us-ff-enterprise resource group

$connection = Get-AutomationConnection -Name AzureRunAsConnection
$connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

$ff_nics = (Get-AzNetworkInterface | where-object { $_.ResourceGroupName -eq "rg-north-central-us-ff-enterprise"} | where-object { $_.VirtualMachine -eq $null})

foreach ($nic in $ff_nics) {
	$pip_prefix = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/rg-north-central-us-ff-enterprise/providers/Microsoft.Network/publicIPAddresses/"
	$nic_object = Get-AzNetworkInterface -Name $nic.Name -ResourceGroupName $nic.ResourceGroupName
	write-host prefix is $pip_prefix
	$pIP = ($nic.IpConfigurations.PublicIpAddress.Id -replace $pip_prefix)
	write-output ('Removing NIC and configuration for {0}' -f $nic.Name)
	write-output ('Will remove Public IP: {0}' -f $pIP)
	write-output "$null"
	Remove-AzNetworkInterfaceIpConfig  -Name IPConfig-1 -NetworkInterface $nic_object
	Remove-AzNetworkInterface -Name $nic.Name -ResourceGroup $nic.ResourceGroupName -force
	Remove-AzPublicIpAddress -Name $pIP -ResourceGroup $nic.ResourceGroupName -force
}

write-output "Removing unattached disks"
write-output "$null"
$managedDisks = ( Get-AzDisk  | where-object { $_.ResourceGroupName -eq "rg-north-central-us-ff-enterprise"} | where-object { $_.ManagedBy -eq $null})
foreach ($md in $managedDisks) {
	$disk_prefix = "/subscriptions/108d46d5-fe9b-4850-9a7d-8c914aa6c1f0/resourceGroups/RG-NORTH-CENTRAL-US-FF-ENTERPRISE/providers/Microsoft.Compute/disks/"
	$d_id = ($md.Id -replace $disk_prefix)
	write-output ('Deleting Disk with Id: {0}' -f $d_id)
	write-output "$null"
	$md | Remove-AzDisk -Force
}
