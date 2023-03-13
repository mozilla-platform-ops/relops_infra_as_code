# If a packer fails to complete a build it will orphan the resource group.
# Refrence https://github.com/mozilla-platform-ops/cloud-image-builder/blob/6d2c7084c69ee6af9f033e71d8dc40495cc0c18f/packer/build-packer-image.ps1#L102

$subscriptionID = "108d46d5-fe9b-4850-9a7d-8c914aa6c1f0"
$uamiID ="6061cb58-20ec-49ae-9af3-a7c84118bbe9"
Connect-AzAccount -Identity -AccountId $uamiID
Set-AzContext -Subscription $subscriptionID

$resource_groups = (Get-AzResourceGroup -Name "*tmp3")

foreach ($rg in $resource_groups) {
    Write-Output Removing $rg.ResourceGroupName.
    Get-AzResourceGroup -Name $rg.ResourceGroupName | Remove-AzResourceGroup -Force
}
