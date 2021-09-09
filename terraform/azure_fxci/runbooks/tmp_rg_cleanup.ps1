# If a packer fails to complete a build it will orphan the resource group.
# Refrence https://github.com/mozilla-platform-ops/cloud-image-builder/blob/6d2c7084c69ee6af9f033e71d8dc40495cc0c18f/packer/build-packer-image.ps1#L102

$connection = Get-AutomationConnection -Name AzureRunAsConnection
$connectionResult = Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

$resource_groups = (Get-AzResourceGroup -Name "*tmp3")

foreach ($rg in $resource_groups) {
    Write-Output Removing $rg.ResourceGroupName.
    Get-AzResourceGroup -Name $rg.ResourceGroupName | Remove-AzResourceGroup -Force
}
