<#
  File: Add-UpdateEntry.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.1
  Change Log:
    - 1.0 Initial helper to safely update updates.json
    - 1.1 Add optional Build support
#>

param (
    [Parameter(Mandatory)][string]$Id,
    [Parameter(Mandatory)][string]$Version,
    [string]$Build,
    [Parameter(Mandatory)][datetime]$ReleaseDate,
    [string]$Notes = 'Update recorded'
)

$data = Get-Content .\updates.json -Raw | ConvertFrom-Json
$update = $data.updates | Where-Object id -eq $Id
if (-not $update) { throw "No update entry found with id '$Id'" }

$current = @{
    version      = $Version
    release_date = $ReleaseDate.ToString('yyyy-MM-dd')
}
if ($Build) { $current.build = $Build }

$update.current = $current

$history = @{
    version      = $Version
    release_date = $ReleaseDate.ToString('yyyy-MM-dd')
    noted_on     = (Get-Date).ToString('yyyy-MM-dd')
    notes        = $Notes
}
if ($Build) { $history.build = $Build }

$update.history = @($history) + $update.history
$data.last_updated = (Get-Date).ToString('yyyy-MM-dd')

$data | ConvertTo-Json -Depth 6 | Set-Content .\updates.json -Encoding UTF8

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
