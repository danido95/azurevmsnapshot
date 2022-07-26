function New-AzureVMSnapshot {
    <#
    .SYNOPSIS
    Create a snapshot of the OS disk of a (running) Azure VM.
    .DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
    .NOTES
    This function requires the Azure CLI from Microsoft. After install run 'az login'
    .LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
    .Parameter ResourceGroupName
    Parameter Description
    .Parameter VirtualMachineName
    Parameter Description
    .Parameter SnapshotName
    Parameter Description
    .EXAMPLE
    New-AzVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm-001 -SnapshotName 'vm-001-snapshot'
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$resourceGroupName,
        [Parameter()][string]$virtualMachineName,
        [Parameter()][string]$snapshotName
    )

    if ($(Get-AzureCLIStatus) -ne 0){
        throw "Please check the Azure CLI Error messages."
    }

    $resourceGroupName = Confirm-RessourceGroupName -resourceGroupName $resourceGroupName
    $virtualMachineName = Confirm-VirtualMachineName -resourceGroupName $resourceGroupName -virtualMachineName $virtualMachineName
    $snapshotList = Confirm-SnapshotList -resourceGroupName $resourceGroupName

    # Validate snapshot name
    if ((!$snapshotName) -or ($snapshotList -contains $snapshotName)) {
        Write-Host "No snapshot name provided or provided snapshot name already taken at '$resourceGroupName'." -ForegroundColor DarkYellow
        $snapshotName = Read-Host -Prompt (Write-Host "`nEnter name for the snapshot to create: " -ForegroundColor DarkYellow)

        while ($snapshotList -match $snapshotName) {
            Write-Host "A snapshot with this name already exists in the current resource group '$resourceGroupName'." -ForegroundColor Red
            $snapshotName = Read-Host -Prompt (Write-Host "`nEnter name for the snapshot to create: " -ForegroundColor DarkYellow)
        }
    }

    # Collection vm information
    Write-Host "`nGetting VM Information..." -ForegroundColor DarkGray
    $vmLocation = az vm show -g $resourceGroupName -n $virtualMachineName --query location -o tsv
    $currentDiskID = az vm show -g $resourceGroupName -n $virtualMachineName --query storageProfile.osDisk.managedDisk.id -o tsv
    Write-Host "`nVM Location: $vmLocation`nCurrent Disk ID: $currentDiskID"

    # Handle snapshot creation
    $title    = "Confirm"
    $question = "Are you sure you want to perform this action? `nPerforming the operation: Create snapshot '$snapshotName' of '$virtualMachineName' in resource group '$resourceGroupName' at location '$vmLocation'."
    $choices  = "&Yes", "&No"
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
    if ($decision -eq 0) {
        Write-Host "`nCreating snapshot with name '$snapshotName' of vm '$virtualMachineName' in resource group '$resourceGroupName' at location '$vmLocation'." -ForegroundColor Yellow

        $snapshotID = az snapshot create -g $resourceGroupName -n $snapshotName -l $vmLocation --source $currentDiskId --query id -o tsv
        if ($lastexitcode -ne 0) {
            throw "`nError creating snapshot"
        }

        Write-Host "`nCreated snapshot with ID:`n$snapshotID`n`nDone`n" -ForegroundColor Green
    } 
    else {
        Write-Host "`nAction chancled by user." -ForegroundColor Red
    }
}