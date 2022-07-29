# Azure VM Snapshot Module
Interactive PowerShell Script to create and restore snapshots of the OS disk of Azure VMs.

Info: Azure only supports snapshots of disks, there is no possibility to perform a memory snapshot!

# Prequesites
- Install Azure CLI from Microsoft: https://docs.microsoft.com/de-de/cli/azure/install-azure-cli
- Install / Import this Module
- Before using perform 'az login'

# Installation
You can download the files an copy then directly into your PowerShell module path or simply install it via PowerShell from the PowerShell Gallery (https://www.powershellgallery.com/packages/AzureVMSnapshot).

```powershell
Install-Module -Name AzureVMSnapshot
```

# Usage Examples
## Example 1
This example shoul demonstrate you how to work with the module interactive (without providing parameters)
```powershell
PS C:\Users\user.name> az login
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.                                                               [
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "00000000-0000-0000-0000-000000000000",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "managedByTenants": [],
    "name": "<tenantname>",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "admin@<tenantname>.onmicrosoft.com",
      "type": "user"
    }
  }
]
PS C:\Users\user.name> Import-Module -Name AzureVMSnapshot
PS C:\Users\user.name> Get-AzureVMSnapshot

Checking Azure CLI Version...
Azure CLI Version 2.38.0 is installed.

Checking Account...
Username: admin@<tenantname>.onmicrosoft.com
Tenant ID: 00000000-0000-0000-0000-000000000000
Subscription: <subscriptionname>

Fetching available resource groups in your subscription...
No resource group provided or provided resource group not found.
Choose resource group:
[0]: Cancel
[1]: test-001-rg
[2]: test-002-rg
[3]: test-003-rg
[4]: test-004-rg
[5]: example-rg
3
Choosen resource group: 'test-003-rg'

Fetching available snapshots in group 'test-003-rg'...
There are no snapshots in resource group 'test-003-rg'.
````
## Example 2
Create a new snapshot for a specific VM when all parameters are known. 
```powershell
New-AzureVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm001' -SnapshotName 'vm001-snapshot001'
```
## Example 3
Get a list of all snapshots in a resource group.
```powershell
Get-AzureVMSnapshot -ResourceGroupName 'example-rg'
```
## Example 4
Restore the above created snapshot to the VM:
```powershell
Restore-AzureVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm001' -SnapshotName 'vm001-snapshot001'
```
## Example 5
Remove the above created snapshot:
```powershell
Restore-AzureVMSnapshot -ResourceGroupName 'example-rg' -SnapshotName 'vm001-snapshot001'
```
