# Reference: https://mozilla-hub.atlassian.net/browse/RELOPS-231
# Temp solution to remove old NV6 VMs

$connection = Get-AutomationConnection -Name AzureRunAsConnection
$connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

$current = (get-date -format g)
$vms = (get-azvm)
$current = ((Get-Date).ToUniversalTime())

foreach ($vm in $vms) {
	if ($VM.HardwareProfile.VMSize -eq "Standard_NV6") {
		$status = (get-azvm -resourcegroup $vm.ResourceGroupName -name $vm.Name -status -ErrorAction:SilentlyContinue)
		$provisioned_time = $status.Disks[0].Statuses[0].Time
		$up_time = (New-TimeSpan -Start $provisioned_time -end $current -ErrorAction:SilentlyContinue)
		$hrs = $up_time.hours
		$dys = $up_time.days
		[int]$hrs_up = ($dys * 24) + $hrs
		if ($hrs_up -ge 12) {
			Write-Output ('ID: {0} Location: {1} up_time: {2} hrs Name: {3}' -f $vm.VmID, $vm.location, $hrs_up, $vm.Name)
			Remove-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
		}
	}
}
