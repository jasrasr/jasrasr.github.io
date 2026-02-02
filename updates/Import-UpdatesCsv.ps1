#Requires -Version 7.0
<#
  File: Import-UpdatesCsv.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.4
  Change Log:
    - 1.0 Initial CSV import
    - 1.1 ImportStatus column
    - 1.2 Add Build field
    - 1.3 Bug fixes and cleanup
    - 1.4 PS7-only, simplified null handling, final schema alignment
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [string]$JsonPath = '.\updates.json'
)

# ------------------------------------------------------------
# Load files
# ------------------------------------------------------------

if (-not (Test-Path $CsvPath)) {
    throw "CSV file not found: $CsvPath"
}

if (-not (Test-Path $JsonPath)) {
    throw "updates.json not found: $JsonPath"
}

$data = Get-Content $JsonPath -Raw | ConvertFrom-Json
$existingIds = @($data.updates.id)

$rows = Import-Csv $CsvPath

# Ensure ImportStatus column exists
if (-not ($rows | Get-Member -Name ImportStatus)) {
    $rows | ForEach-Object {
        $_ | Add-Member -MemberType NoteProperty -Name ImportStatus -Value ''
    }
}

$newEntries = @()

# ------------------------------------------------------------
# Process rows
# ------------------------------------------------------------

foreach ($row in $rows) {

    $row.ImportStatus = ''

    $required = @(
        'Id','Name','Vendor','Category',
        'Version','ReleaseDate',
        'SourceType','SourceUrl'
    )

    $missing = $required | Where-Object { -not $row.$_ }

    if ($missing) {
        $row.ImportStatus = "Error: Missing $($missing -join ', ')"
        continue
    }

    if ($existingIds -contains $row.Id) {
        $row.ImportStatus = 'Skipped (Exists)'
        continue
    }

    # ---- Normalize values -------------------------------------

    $notes = $row.Notes ?? 'Initial tracking entry'
    $requiresReboot = [bool]($row.RequiresReboot ?? $false)

    # ---- Current ----------------------------------------------

    $current = [ordered]@{
        version      = $row.Version
        release_date = ([datetime]$row.ReleaseDate).ToString('yyyy-MM-dd')
    }

    if ($row.Build) {
        $current.build = $row.Build
    }

    # ---- History ----------------------------------------------

    $history = [ordered]@{
        version      = $row.Version
        release_date = ([datetime]$row.ReleaseDate).ToString('yyyy-MM-dd')
        noted_on     = (Get-Date).ToString('yyyy-MM-dd')
        notes        = $notes
    }

    if ($row.Build) {
        $history.build = $row.Build
    }

    # ---- Assemble entry ---------------------------------------

    $newEntries += [ordered]@{
        id       = $row.Id
        name     = $row.Name
        vendor   = $row.Vendor
        category = $row.Category

        current  = $current

        source   = [ordered]@{
            type = $row.SourceType
            url  = $row.SourceUrl
        }

        install  = [ordered]@{
            method          = $row.InstallMethod
            package_manager = $row.PackageManager
        }

        upgrade  = [ordered]@{
            method          = $row.UpgradeMethod
            path            = $row.UpgradePath
            requires_reboot = $requiresReboot
        }

        history  = @($history)
    }

    $row.ImportStatus = 'Added'
}

# ------------------------------------------------------------
# Write JSON
# ------------------------------------------------------------

if ($newEntries.Count -gt 0 -and
    $PSCmdlet.ShouldProcess('updates.json', "Add $($newEntries.Count) new entries")) {

    $data.updates += $newEntries
    $data.last_updated = (Get-Date).ToString('yyyy-MM-dd')

    $data |
        ConvertTo-Json -Depth 6 |
        Set-Content -Path $JsonPath -Encoding UTF8
}

# ------------------------------------------------------------
# Write CSV back
# ------------------------------------------------------------

$rows | Export-Csv $CsvPath -NoTypeInformation

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host "----------------------------------------"
Write-Host "Import Summary" -ForegroundColor Green
Write-Host "  Added   : $($rows | Where-Object ImportStatus -eq 'Added' | Measure-Object | Select-Object -Expand Count)"
Write-Host "  Skipped : $($rows | Where-Object ImportStatus -eq 'Skipped (Exists)' | Measure-Object | Select-Object -Expand Count)"
Write-Host "  Errors  : $($rows | Where-Object ImportStatus -like 'Error*' | Measure-Object | Select-Object -Expand Count)"


# ------------------------------------------------------------
# Usage Examples
# ------------------------------------------------------------

<#
# Dry run
.\Import-UpdatesCsv.ps1 -CsvPath .\updates-import.csv -WhatIf

# Actual import
.\Import-UpdatesCsv.ps1 -CsvPath .\updates-import.csv
#>