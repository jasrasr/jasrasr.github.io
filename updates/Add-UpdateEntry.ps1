<#
  File: Add-UpdateEntry.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.0
  Change Log:
    - 1.0 Initial helper to safely update updates.json
#>

param (
    [Parameter(Mandatory)]
    [string]$Id,

    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [datetime]$ReleaseDate,

    [string]$Notes = '',

    [string]$JsonPath = '.\updates.json'
)

# --- Validation ----------------------------------------------------

if (-not (Test-Path $JsonPath)) {
    throw "updates.json not found at path: $JsonPath"
}

# --- Load JSON -----------------------------------------------------

$jsonRaw = Get-Content $JsonPath -Raw
$data    = $jsonRaw | ConvertFrom-Json

$update = $data.updates | Where-Object { $_.id -eq $Id }

if (-not $update) {
    throw "No update entry found with id '$Id'"
}

# --- Preserve existing current into history -----------------------

$existing = $update.current

$historyEntry = [ordered]@{
    version      = $Version
    release_date = $ReleaseDate.ToString('yyyy-MM-dd')
    noted_on     = (Get-Date).ToString('yyyy-MM-dd')
    notes        = $Notes
}

# --- Insert new history entry (newest first) ----------------------

$update.history = @($historyEntry) + $update.history

# --- Update current ------------------------------------------------

$update.current.version      = $Version
$update.current.release_date = $ReleaseDate.ToString('yyyy-MM-dd')

# --- Update root metadata -----------------------------------------

$data.last_updated = (Get-Date).ToString('yyyy-MM-dd')

# --- Write JSON back (stable formatting) ---------------------------

$data |
    ConvertTo-Json -Depth 6 |
    Set-Content -Path $JsonPath -Encoding UTF8

Write-Host "Update applied successfully:" -ForegroundColor Green
Write-Host "  ID       : $Id"
Write-Host "  Version  : $Version"
Write-Host "  Released : $($ReleaseDate.ToString('yyyy-MM-dd'))"

<#
# Example 1: Add a new PowerShell release
.\Add-UpdateEntry.ps1 `
  -Id 'powershell' `
  -Version '7.4.2' `
  -ReleaseDate '2026-02-01' `
  -Notes 'Bug fixes and performance improvements'

# Example 2: Update Notepad++
.\Add-UpdateEntry.ps1 `
  -Id 'notepadpp' `
  -Version '8.6.4' `
  -ReleaseDate '2026-01-28' `
  -Notes 'Security fixes'
#>
