function Get-AzureVMSnapshot {
    <#
    .SYNOPSIS
    Get a list of snapshot in given resource group.
    .DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
    .NOTES
    This function requires the Azure CLI from Microsoft. After install run 'az login'
    .LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
    .Parameter ResourceGroupName
    Parameter Description
    .EXAMPLE
    Get-AzVMSnapshot -ResourceGroupName 'example-rg'
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$resourceGroupName
    )

    if ($(Get-AzureCLIStatus) -ne 0){
        throw "Please check the Azure CLI Error messages."
    }

    $resourceGroupName = Confirm-RessourceGroupName -resourceGroupName $resourceGroupName
    $snapshotList = Confirm-SnapshotList -resourceGroupName $resourceGroupName
    Write-Host $snapshotList
}