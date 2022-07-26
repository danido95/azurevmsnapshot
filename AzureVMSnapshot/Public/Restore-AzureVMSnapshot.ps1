function Restore-AzureVMSnapshot {
    <#
    .SYNOPSIS
    Restore a snapshot from the OS disk of a (running) Azure VM.
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
    Restore-AzVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm-001 -SnapshotName 'vm-001-snapshot'
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$resourceGroupName,
        [Parameter()][string]$virtualMachineName,
        [Parameter()][string]$snapshotName
    )

    if ($(Get-AzureCLIStatus) -ne 0){
        throw "`nPlease check the Azure CLI Error messages."
    }

    $resourceGroupName = Confirm-RessourceGroupName -resourceGroupName $resourceGroupName
    $virtualMachineName = Confirm-VirtualMachineName -resourceGroupName $resourceGroupName -virtualMachineName $virtualMachineName
    $snapshotList = Confirm-SnapshotList -resourceGroupName $resourceGroupName

    # Validate snapshot name
    if ((!$snapshotName) -or ($snapshotList -notcontains $snapshotName)) {
        $snapshotName = (Get-SelectionFromUser -Options $snapshotList -Prompt "Choose snapshot to restore to vm '$virtualMachineName'")
    }

    # Collection vm information
    Write-Host "`nGetting VM Information..." -ForegroundColor DarkGray
    $vmID = az vm show -g $resourceGroupName -n $virtualMachineName --query id -o tsv
    $vmLocation = az vm show -g $resourceGroupName -n $virtualMachineName --query location -o tsv
    $vmGeneration = az vm get-instance-view -g $resourceGroupName -n $virtualMachineName --query instanceView.hyperVGeneration -o tsv
    $currentDiskID = az vm show -g $resourceGroupName -n $virtualMachineName --query storageProfile.osDisk.managedDisk.id -o tsv
    $snapshotID = az snapshot show -n $snapshotName -g $resourceGroupName --query id -o tsv
    $newDiskName = "$virtualMachineName-$snapshotName-$(Get-Date -format "yyyyMMdd-HHmmss")"
    Write-Host "`VM ID: $vmID`nVM Location: $vmLocation`nVM Generation: $vmGeneration`nCurrent Disk ID: $currentDiskID`nSnapshot ID: $snapshotID`nNew Disk Name: $newDiskName"

    # Handle snapshot restore
    $title    = "Confirm"
    $question = "Are you sure you want to perform this action? `nPerforming the operation: Restore snapshot '$snapshotName' to '$virtualMachineName' in resource group '$resourceGroupName' at location '$vmLocation'. `nThe VM will be shutdown and the current OS disk of the VM will be destroyed. The snapshot remains available."
    $choices  = "&Yes", "&No"
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
    if ($decision -eq 0) {
        Write-Host "`nRestoring snapshot with name '$snapshotName' to vm '$virtualMachineName' in resource group '$resourceGroupName' at location '$vmLocation'." -ForegroundColor Yellow

        # Create new disk from snapshot
        $newDiskID = az disk create --resource-group $resourceGroupName --name $newDiskName  --location $vmLocation --hyper-v-generation $vmGeneration --sku Standard_LRS --source $snapshotID --query id -o tsv
        if ($lastexitcode -ne 0) {
            throw "`nCould not create a new disk from snapshot"
        }
        Write-Host "`nCreated new disk with ID '$newDiskID'" -ForegroundColor Green

        # Stop and deallocate the VM
        Write-Host "`nStopping the VM..." -ForegroundColor DarkGray
        az vm stop --ids $vmID
        if ($lastexitcode -ne 0) {
            throw "`nCould not stop the VM" 
        }
        Write-Host "VM Stopped." -ForegroundColor Yellow
        Write-Host "`nDeallocating the VM..." -ForegroundColor DarkGray
        az vm deallocate --ids $vmID
        if ($lastexitcode -ne 0) {
            throw "`nCould not deallocate the VM"
        }
        Write-Host "VM deallocated." -ForegroundColor Yellow
        Write-Host "`nUpdating the VM to use the new disk..." -ForegroundColor DarkGray
        az vm update --ids $vmID --os-disk $newDiskID
        if ($lastexitcode -ne 0) {
            throw "`nCould not update the VM."
        }
        Write-Host "VM updated!" -ForegroundColor Green 
        Write-Host "`nStarting the VM..." -ForegroundColor DarkGray
        az vm start --ids $vmID
        if ($lastexitcode -ne 0) {
            throw "`nCould not update the VM `nStarting the VM failed. You need to manually: `n-Start the VM: '$AZ vm start --ids $vm_id' `n-Delete the old disk: '$AZ disk delete --ids $current_disk_id' `n(Because the VM was deallocated, starting sometimes fails when Azure does not have enough VMs of the required type avaiable)"
        }
        Write-Host "VM started!" -ForegroundColor Green

        Write-Host "`nDeleting the old disk with id '$currentDiskID'..." -ForegroundColor DarkGray
        az disk delete --ids $currentDiskID --verbose --yes
        Write-Host "Deleted the old disk.`n`nDone!`n" -ForegroundColor Green
    } 
    else {
        Write-Host "`nAction chancled by user." -ForegroundColor Red
    }
}