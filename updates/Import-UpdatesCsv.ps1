<#
  File: Import-UpdatesCsv.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.1
  Change Log:
    - 1.0 Initial bulk CSV import helper
    - 1.1 Write per-row ImportStatus back to CSV
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

if (-not ($rows | Get-Member -Name ImportStatus)) {
    $rows | ForEach-Object { $_ | Add-Member ImportStatus '' }
}

$newEntries = @()

# ------------------------------------------------------------
# Process rows
# ------------------------------------------------------------

foreach ($row in $rows) {

    $row.ImportStatus = ''

    $required = @('Id','Name','Vendor','Category','Version','ReleaseDate','SourceType','SourceUrl')
    $missing  = $required | Where-Object { -not $row.$_ }

    if ($missing) {
        $row.ImportStatus = "Error: Missing $($missing -join ', ')"
        continue
    }

    if ($existingIds -contains $row.Id) {
        $row.ImportStatus = 'Skipped (Exists)'
        continue
    }

    try {
        $entry = [ordered]@{
            id       = $row.Id
            name     = $row.Name
            vendor   = $row.Vendor
            category = $row.Category

            current = [ordered]@{
                version      = $row.Version
                release_date = ([datetime]$row.ReleaseDate).ToString('yyyy-MM-dd')
            }

            source = [ordered]@{
                type = $row.SourceType
                url  = $row.SourceUrl
            }

            install = [ordered]@{
                method          = $row.InstallMethod
                package_manager = $row.PackageManager
                silent_switches = $null
            }

            upgrade = [ordered]@{
                method          = $row.UpgradeMethod
                path            = $row.UpgradePath
                requires_reboot = [bool]::Parse($row.RequiresReboot ?? 'false')
            }

            history = @(
                [ordered]@{
                    version      = $row.Version
                    release_date = ([datetime]$row.ReleaseDate).ToString('yyyy-MM-dd')
                    noted_on     = (Get-Date).ToString('yyyy-MM-dd')
                    notes        = $row.Notes ?? 'Initial tracking entry'
                }
            )
        }

        $newEntries += $entry
        $row.ImportStatus = 'Added'
    }
    catch {
        $row.ImportStatus = "Error: $_"
    }
}

# ------------------------------------------------------------
# Write JSON
# ------------------------------------------------------------

if ($newEntries.Count -gt 0 -and $PSCmdlet.ShouldProcess('updates.json', 'Add new update entries')) {
    $data.updates += $newEntries
    $data.last_updated = (Get-Date).ToString('yyyy-MM-dd')

    $data |
        ConvertTo-Json -Depth 6 |
        Set-Content -Path $JsonPath -Encoding UTF8
}

# ------------------------------------------------------------
# Write CSV back
# ------------------------------------------------------------

if ($PSCmdlet.ShouldProcess($CsvPath, 'Update ImportStatus column')) {
    $rows | Export-Csv $CsvPath -NoTypeInformation
}

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
