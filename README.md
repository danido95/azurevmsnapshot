# Azure VM Snapshot Module
Interactive PowerShell Script to create and restore snapshots of the OS disk of Azure VMs.

Info: Azure only supports snapshots of disks, there is no possibility to perform a memory snapshot!

# Prequesites
- Install Azure CLI from Microsoft: https://docs.microsoft.com/de-de/cli/azure/install-azure-cli
- Install / Import this Module
- Before using perform 'az login'

# Installation
You can download the files an copy then directly into your PowerShell module path or simply install it via PowerShell from the PowerShell Gallery (https://www.powershellgallery.com/packages/AzureVMSnapshot/0.0.1).

```powershell
Install-Module -Name AzureVMSnapshot
```

# Usage Example
All of the commands could be used interactive with no parameters given. The Script than fetches information from you Azure Tenant.

Create a new snapshot for a specific VM when all parameters are known. 
```powershell
New-AzureVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm001' -SnapshotName 'vm001-snapshot001'
```
Get a list of all snapshots in a resource group.
```powershell
Get-AzureVMSnapshot -ResourceGroupName 'example-rg'
```
Restore the above created snapshot to the VM:
```powershell
Restore-AzureVMSnapshot -ResourceGroupName 'example-rg' -VirtualMachineName 'vm001' -SnapshotName 'vm001-snapshot001'
```
Remove the above created snapshot:
```powershell
Restore-AzureVMSnapshot -ResourceGroupName 'example-rg' -SnapshotName 'vm001-snapshot001'
```