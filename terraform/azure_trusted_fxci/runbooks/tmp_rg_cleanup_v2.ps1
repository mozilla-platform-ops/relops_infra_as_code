# If a packer fails to complete a build it will orphan the resource group.
# Refrence https://github.com/mozilla-platform-ops/cloud-image-builder/blob/6d2c7084c69ee6af9f033e71d8dc40495cc0c18f/packer/build-packer-image.ps1#L102

$subscriptionID = "a30e97ab-734a-4f3b-a0e4-c51c0bff0701"
$uamiID ="6ccfd5c0-507b-45e5-b5c3-ba17bb67c762"
Connect-AzAccount -Identity -AccountId $uamiID
Set-AzContext -Subscription $subscriptionID

$resource_groups = (Get-AzResourceGroup -Name "*tmp3")

foreach ($rg in $resource_groups) {
    Write-Output Removing $rg.ResourceGroupName.
    Get-AzResourceGroup -Name $rg.ResourceGroupName | Remove-AzResourceGroup -Force
}
