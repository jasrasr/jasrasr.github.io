<#
  File: New-UpdateEntry.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.0
  Change Log:
    - 1.0 Initial helper to create new update entries
#>

param (
    [Parameter(Mandatory)]
    [string]$Id,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Vendor,

    [Parameter(Mandatory)]
    [string]$Category,

    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [datetime]$ReleaseDate,

    [Parameter(Mandatory)]
    [string]$SourceType,

    [Parameter(Mandatory)]
    [string]$SourceUrl,

    [string]$InstallMethod = 'manual',
    [string]$PackageManager,
    [string]$UpgradeMethod = 'in-place',
    [string]$UpgradePath = '',
    [bool]$RequiresReboot = $false,

    [string]$Notes = 'Initial tracking entry',

    [string]$JsonPath = '.\updates.json'
)

# --- Validation ----------------------------------------------------

if (-not (Test-Path $JsonPath)) {
    throw "updates.json not found at path: $JsonPath"
}

$jsonRaw = Get-Content $JsonPath -Raw
$data    = $jsonRaw | ConvertFrom-Json

if ($data.updates.id -contains $Id) {
    throw "An update entry with id '$Id' already exists"
}

# --- Build new entry ----------------------------------------------

$newEntry = [ordered]@{
    id       = $Id
    name     = $Name
    vendor   = $Vendor
    category = $Category

    current = [ordered]@{
        version      = $Version
        release_date = $ReleaseDate.ToString('yyyy-MM-dd')
    }

    source = [ordered]@{
        type = $SourceType
        url  = $SourceUrl
    }

    install = [ordered]@{
        method          = $InstallMethod
        package_manager = $PackageManager
        silent_switches = $null
    }

    upgrade = [ordered]@{
        method           = $UpgradeMethod
        path             = $UpgradePath
        requires_reboot  = $RequiresReboot
    }

    history = @(
        [ordered]@{
            version      = $Version
            release_date = $ReleaseDate.ToString('yyyy-MM-dd')
            noted_on     = (Get-Date).ToString('yyyy-MM-dd')
            notes        = $Notes
        }
    )
}

# --- Insert entry --------------------------------------------------

$data.updates += $newEntry
$data.last_updated = (Get-Date).ToString('yyyy-MM-dd')

# --- Write JSON ----------------------------------------------------

$data |
    ConvertTo-Json -Depth 6 |
    Set-Content -Path $JsonPath -Encoding UTF8

Write-Host "New update entry created:" -ForegroundColor Green
Write-Host "  ID      : $Id"
Write-Host "  Name    : $Name"
Write-Host "  Version : $Version"

<#
.\New-UpdateEntry.ps1 `
  -Id 'powershell' `
  -Name 'PowerShell' `
  -Vendor 'Microsoft' `
  -Category 'Shell / Automation' `
  -Version '7.4.2' `
  -ReleaseDate '2026-02-01' `
  -SourceType 'github' `
  -SourceUrl 'https://github.com/PowerShell/PowerShell/releases' `
  -InstallMethod 'package_manager' `
  -PackageManager 'winget' `
  -UpgradeMethod 'in-place' `
  -UpgradePath 'winget upgrade Microsoft.PowerShell'
#>
