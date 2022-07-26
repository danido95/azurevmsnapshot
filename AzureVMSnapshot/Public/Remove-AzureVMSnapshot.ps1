function Remove-AzureVMSnapshot {
    <#
    .SYNOPSIS
    Remove a snapshot.
    .DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
    .NOTES
    This function requires the Azure CLI from Microsoft. After install run 'az login'
    .LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
    .Parameter ResourceGroupName
    Parameter Description
    .Parameter SnapshotName
    Parameter Description
    .EXAMPLE
    Remove-AzVMSnapshot -ResourceGroupName 'example-rg' -SnapshotName 'vm-001-snapshot'
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$resourceGroupName,
        [Parameter()][string[]]$snapshotName
    )

    if ($(Get-AzureCLIStatus) -ne 0){
        throw "Please check the Azure CLI Error messages."
    }

    $resourceGroupName = Confirm-RessourceGroupName -resourceGroupName $resourceGroupName
    $snapshotList = Confirm-SnapshotList -resourceGroupName $resourceGroupName

    # Validate snapshot name
    if (!$snapshotName) {
        $snapshotName += (Get-SelectionFromUser -Options $snapshotList -Prompt "Choose snapshot to remove:")
    }

    foreach ($snapshot in $snapshotName) {
        if ($snapshotList -notcontains $snapshot) {
            Write-Host "Given snapshot '$snapshot' does not exist in resource group '$resourceGroupName'." -ForegroundColor Yellow
        }
        else {
            # Handle snapshot removal
            $title    = "Confirm"
            $question = "Are you sure you want to perform this action? `nPerforming the operation: Delete snapshot '$snapshot' in resource group '$resourceGroupName'."
            $choices  = "&Yes", "&No"
            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
            if ($decision -eq 0) {
                Write-Host "`nRemoving snapshot with name '$snapshot' in resource group '$resourceGroupName'." -ForegroundColor Yellow

                az snapshot delete --resource-group $resourceGroupName --name $snapshot
                if ($lastexitcode -ne 0) {
                    throw "`nError removing snapshot"
                }

                Write-Host "`nRemoved snapshot with name:`n$snapshot`n`nDone`n" -ForegroundColor Green
            } 
            else {
            Write-Host "`nAction chancled by user." -ForegroundColor Red
            }
        }
    }
}