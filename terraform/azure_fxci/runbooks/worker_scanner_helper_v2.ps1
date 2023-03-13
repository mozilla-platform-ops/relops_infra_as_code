# This is a helper script for worker-scanner
# The intent is to remove unattached resources from deleted VMs
# and reduce the the disparage in worker-manager poll capacities.

# Determines disk with null value for managed by as old

$subscriptionID = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
$uamiID ="6061cb58-20ec-49ae-9af3-a7c84118bbe9"
Connect-AzAccount -Identity -AccountId $uamiID
Set-AzContext -Subscription $subscriptionID

$d = 0

write-output "Removing unattached disks"

$managedDisks = Get-AzDisk
foreach ($md in $managedDisks) {
    if(($md.ManagedBy -eq $null) -and ($md.ResourceGroupName -eq $target_group)) {
		write-output ('Deleting Disk with Id: {0}' -f $md.Id)
		$md | Remove-AzDisk -Force

		$d = ($d + 2)
    }
 }

write-output "Total number of disks (2 per VM) removed: $d"
