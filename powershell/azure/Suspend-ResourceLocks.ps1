<#
.SYNOPSIS
Removes all locks on an object, pause until user input and recreate the locks.

.DESCRIPTION
The script will locate the Azure object based on it's name and then will get a list of all locks associated with it and it's parent.
It will then remove all locks then pause the script so the user can work on the resource. Once done, the locks will be recreated as they were.
Press tab to go through the predefined options of the parameter "ResourceType".

Exit code -1 : Script encountered an error.
Exit code 0 : Script was successful.
Exit code 1 : Script found no locks on the object and exited successfully.

.EXAMPLE 
./Suspend-ResourceLock.ps1 -ResourceName someResource -ResourceType Resource
./Suspend-ResourceLock.ps1 -ResourceName someResource -ResourceType ResourceGroup

#>

#Requires -Modules Az.Resources

Param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceName,
    [ValidateSet('ResourceGroup','Resource')]
    [string]$ResourceType
)

$ErrorActionPreference = 'Stop'
$azureContext = Get-AzContext

if (!$azureContext) {
    $azureCreds = Get-Credential -Message "Enter your Azure credentials."
    Connect-AzAccount -Credential $azureCreds
}

function Get-AllLocksOnObject {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$InputResource,
        [string]$InputResourceType
    )

    $allLockObjects = @()

    switch ($InputResourceType) {
         'ResourceGroup' {
            $allLocksFound = Get-AzResourceLock -ResourceGroupName $InputResource
         }
         'Resource' {
            $resourceObject = Get-AzResource -Name $InputResource

            if (!$resourceObject) {
                Write-Warning 'No object found, make sure the object exists and you are in the right context.'
                Exit -1
            }

            $resourceType = $resourceObject.ResourceType
            $resourceGroupName = $resourceObject.ResourceGroupName
            $allLocksFound = Get-AzResourceLock -ResourceName $InputResource -ResourceType $resourceType -ResourceGroupName $resourceGroupName
         }
    }

    Write-Host ('Number of locks found: {0}' -f $allLocksFound.Count)
    Write-Host

    foreach ($lock in $allLocksFound) {
        $lockObject = @{
            Name = $lock.Name
            LockLevel = $lock.Properties.level
            ResourceGroup = $lock.ResourceGroupName
            Resource = $lock.ResourceName
            ResourceType = $lock.ResourceType
            LockId = $lock.LockId
        }
        
        Write-Host ('Name: {0}' -f $lockObject.Name)
        Write-Host ('Lock Level: {0}' -f $lockObject.LockLevel)

        if ($lock.Properties.notes) {
            $lockObject.Notes = $lock.Properties.notes
            Write-Host ('Lock Notes: {0}' -f $lockObject.Notes)
        }

        Write-Host ('Resource Group Name: {0}' -f $lockObject.ResourceGroup)
        Write-Host ('Resource Name: {0}' -f $lockObject.Resource)
    
        if ($lockObject.ResourceType -contains '/locks') {
            Write-Host 'Resource Type: Resource Group'
        } else {
            Write-Host ('Resource Type: {0}' -f $lockObject.ResourceType)
        }

        Write-Host

        $allLockObjects += $lockObject
    }
    return $allLockObjects
}

function Remove-AllLocksOnObject {
    Param (
        [Parameter(Mandatory = $true)]
        [PSObject[]]$LockObjects
    )

    foreach ($lock in $LockObjects) {
        Try {
            $errorFound = (-not (Remove-AzResourceLock -LockId $lock.LockId -Force))
        }        
        Catch {
            Write-Error ('Could not delete the following lock: {0}. The error is: {1}' -f $lock.Name, $_.Exception.Message)
            Write-Host ''
            $errorFound = $true
        }

        if ($errorFound) {
            return $false
        }

        Write-Host 'Sleeping for 10 seconds before moving on...'
        Write-Host
        Start-Sleep -Seconds 10
    }
    return $true
}

function New-AllLocksOnObject {
    Param (
        [Parameter(Mandatory = $true)]
        [PSObject[]]$LockObjects
    )
    
    foreach ($lock in $LockObjects) {
        $Params = @{
            LockName = $lock.Name
            LockLevel = $lock.LockLevel
            ResourceGroupName = $lock.ResourceGroup
            Force = $true
        }

        if ($lock.Notes) {
            $Params.LockNotes = $lock.Notes
        }

        if ($lock.ResourceType -ne 'Microsoft.Authorization/locks') {
            $Params.ResourceName = $lock.Resource
            $Params.ResourceType = $lock.ResourceType
        }

        Try {
            New-AzResourceLock @Params
        }
        Catch {
            Write-Error ('Could not create the following lock: {0}, on: {1}. The error is: {2}' -f $lock.Name, $lock.Resource, $_.Exception.Message)
            Write-Host
        }
    }
}

$allLocks = Get-AllLocksOnObject -InputResource $ResourceName -InputResourceType $ResourceType

if ($allLocks) {
    $deleteResult = Remove-AllLocksOnObject -LockObjects $allLocks
}else {
    Write-Warning 'No locks found on this object. Exiting...'
    Exit 1
}

if (!$deleteResult) {
    Write-Warning 'At least one error occurred while deleting the locks associated with this resource. Rolling back now...'
    Write-Host
}else {
    [void](Read-Host 'Press Enter to continue once you are done working on the Azure resource.')
}

New-AllLocksOnObject -LockObjects $allLocks