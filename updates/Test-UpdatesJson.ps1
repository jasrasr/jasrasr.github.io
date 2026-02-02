<#
  File: Test-UpdatesJson.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.4
  Change Log:
    - 1.0 Initial validator
    - 1.1 TryParse attempt
    - 1.2 Switch to Get-Date validation
    - 1.3 Add build consistency warnings
    - 1.4 Centralized required-field validation
#>

param (
    [string]$JsonPath = '.\updates.json'
)

# ------------------------------------------------------------
# State + helpers
# ------------------------------------------------------------

$script:HasErrors = $false

function Fail {
    param ([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    $script:HasErrors = $true
}

function Warn {
    param ([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Test-RequiredFields {
    param (
        [Parameter(Mandatory)][object]$Object,
        [Parameter(Mandatory)][string[]]$RequiredFields,
        [Parameter(Mandatory)][string]$Context
    )

    $props = $Object.PSObject.Properties.Name
    foreach ($field in $RequiredFields) {
        if ($props -notcontains $field) {
            Fail "$Context missing required field: $field"
        }
    }
}

# ------------------------------------------------------------
# File existence
# ------------------------------------------------------------

if (-not (Test-Path $JsonPath)) {
    Fail "updates.json not found at path: $JsonPath"
    return
}

# ------------------------------------------------------------
# JSON parse
# ------------------------------------------------------------

try {
    $raw  = Get-Content $JsonPath -Raw
    $data = $raw | ConvertFrom-Json
}
catch {
    Fail "Invalid JSON syntax: $_"
    return
}

# ------------------------------------------------------------
# Top-level structure
# ------------------------------------------------------------

Test-RequiredFields `
    -Object $data `
    -RequiredFields @('schema_version','last_updated','updates') `
    -Context 'Root object'

if (-not ($data.updates -is [System.Collections.IEnumerable])) {
    Fail "'updates' is not an array"
    return
}

# ------------------------------------------------------------
# Duplicate ID check
# ------------------------------------------------------------

$ids = $data.updates.id
$dupes = $ids | Group-Object | Where-Object { $_.Count -gt 1 }

foreach ($d in $dupes) {
    Fail "Duplicate update id found: '$($d.Name)'"
}

# ------------------------------------------------------------
# Per-update validation
# ------------------------------------------------------------

foreach ($update in $data.updates) {

    Test-RequiredFields `
        -Object $update `
        -RequiredFields @(
            'id','name','vendor','category',
            'current','source','install','upgrade','history'
        ) `
        -Context "Update '$($update.id)'"

    # --- current -------------------------------------------------

    Test-RequiredFields `
        -Object $update.current `
        -RequiredFields @('version','release_date') `
        -Context "Update '$($update.id)' current"

    try {
        [void](Get-Date $update.current.release_date)
    }
    catch {
        Fail "Update '$($update.id)' current.release_date is not a valid date"
    }

    # --- history -------------------------------------------------

    if (-not $update.history -or $update.history.Count -eq 0) {
        Fail "Update '$($update.id)' has empty history array"
        continue
    }

    foreach ($h in $update.history) {

        Test-RequiredFields `
            -Object $h `
            -RequiredFields @('version','release_date','noted_on') `
            -Context "Update '$($update.id)' history entry"

        foreach ($df in @('release_date','noted_on')) {
            try {
                [void](Get-Date $h.$df)
            }
            catch {
                Fail "Update '$($update.id)' history has invalid date in $df"
            }
        }
    }

    # --- logical consistency ------------------------------------

    $latestHistory = $update.history | Select-Object -First 1

    if ($latestHistory.version -ne $update.current.version) {
        Warn "Update '$($update.id)' current.version does not match latest history version"
    }

    if ($latestHistory.release_date -ne $update.current.release_date) {
        Warn "Update '$($update.id)' current.release_date does not match latest history release_date"
    }

    # --- build consistency (optional) ---------------------------

    if ($update.current.PSObject.Properties.Name -contains 'build') {

        if (-not ($latestHistory.PSObject.Properties.Name -contains 'build')) {
            Warn "Update '$($update.id)' has current.build but no build in latest history entry"
        }
        elseif ($update.current.build -ne $latestHistory.build) {
            Warn "Update '$($update.id)' build does not match latest history build"
        }
    }
}

# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

Write-Host "----------------------------------------"

if ($script:HasErrors) {
    Write-Host "Validation FAILED" -ForegroundColor Red
}
else {
    Write-Host "Validation PASSED" -ForegroundColor Green
}




# Example Usage
# .\Test-UpdatesJson.ps1
