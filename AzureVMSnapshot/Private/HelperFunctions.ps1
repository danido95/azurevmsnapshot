function Get-AzureCLIStatus {
    
    Write-Host "`nChecking Azure CLI Version..." -ForegroundColor DarkGray
    $azureCLIVersion = (-join (az version) | convertFrom-Json).'azure-cli'

    if ($lastexitcode -ne 0) {
        Write-Host "`nCould not find the 'az' command in the current path. Make sure azure-cli is installed and in the current path." -ForegroundColor Red
        
        Return 1        
    }
    else {
        Write-Host "Azure CLI Version $azureCLIVersion is installed."
        Write-Host "`nChecking Account..." -ForegroundColor DarkGray

        $username = (-join (az account show) | convertFrom-Json).'user'.'name'

        if ($lastexitcode -ne 0){
            Return 1
        }
        else {
            $tenantID = (-join (az account show) | convertFrom-Json).'tenantId'
            $subscriptionName = (-join (az account show) | convertFrom-Json).'name'

            Write-Host "Username: $username`nTenant ID: $tenantID`nSubscription: $subscriptionName"

            Return 0
        }
    }
}

function Get-SelectionFromUser {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options,
        [Parameter(Mandatory=$true)]
        [string]$Prompt        
    )
    
    [int]$Response = 0;
    [bool]$ValidResponse = $false    

    while (!($ValidResponse)) {            
        [int]$OptionNo = 0

        Write-Host $Prompt -ForegroundColor DarkYellow
        Write-Host "[0]: Cancel"

        foreach ($Option in $Options) {
            $OptionNo += 1
            Write-Host ("[$OptionNo]: {0}" -f $Option)
        }

        if ([Int]::TryParse((Read-Host), [ref]$Response)) {
            if ($Response -eq 0) {
                throw "Action chancled by user."
            }
            elseif($Response -le $OptionNo) {
                $ValidResponse = $true
            }
        }
    }

    return $Options.Get($Response - 1)
} 

function Confirm-RessourceGroupName {
    [CmdletBinding()]
    param (
        [Parameter()][string]$resourceGroupName
    )

    Write-Host "`nFetching available resource groups in your subscription..." -ForegroundColor DarkGray
    $resourceGroups = az group list --query [].name -o tsv
    if ($lastexitcode -ne 0) {
        throw "`nCould not fetch resource groups`n"
    }
    elseif (!$resourceGroups) {
        throw "`nNo resource groups could be found in your current subscription.`n"
    }

    if ((!$resourceGroupName) -or ($resourceGroups -notcontains $resourceGroupName)) {
        Write-Host "No resource group provided or provided resource group not found." -ForegroundColor DarkYellow
        $resourceGroupName = (Get-SelectionFromUser -Options $resourceGroups -Prompt "Choose resource group:")
    }
    Write-Host "Choosen resource group: '$resourceGroupName'"
    Return $resourceGroupName
}

function Confirm-VirtualMachineName {
    [CmdletBinding()]
    param (
        [Parameter()][string]$virtualMachineName,
        [Parameter()][string]$resourceGroupName
    )

    Write-Host "`nFetching vm names in resource group '$resourceGroupName'..." -ForegroundColor DarkGray
    $virtualMachineNames = az vm list -g $resourceGroupName --query [].name -o tsv
    if ($lastexitcode -ne 0) {
        throw "Could not fetch vm names in resource group '$resourceGroupName'"
    } 
    elseif (!$virtualMachineNames){
        throw "`nNo vms could be found in resource group 'resourceGroupName'.`n"
    }

    if ((!$virtualMachineName) -or ($virtualMachineNames -notcontains $virtualMachineName)) {
        Write-Host "No vm name provided or provided vm name at resource group '$resourceGroupName' not found." -ForegroundColor DarkYellow
        $virtualMachineName = (Get-SelectionFromUser -Options $virtualMachineNames -Prompt "Choose vm name for which to create a snapshot:")
    }
    Write-Host "Choosen vm: '$virtualMachineName'"
    Return $virtualMachineName
}

function Confirm-SnapshotList {
    param (
        [Parameter()][string]$resourceGroupName
    )

    Write-Host "`nFetching available snapshots in group '$resourceGroupName'..." -ForegroundColor DarkGray
    $snapshotList = az snapshot list -g $resourceGroupName --query [].name -o tsv
    if ($lastexitcode -ne 0) {
        throw "`nCould not fetch snapshots in group '$resourceGroupName'"
    }
    elseif (!$snapshotList) {
        throw "`nThere are no snapshots in resource group '$resourceGroupName'.`n"
    }
    Return $snapshotList
}