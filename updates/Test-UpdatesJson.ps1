<#
  File: Test-UpdatesJson.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.2
  Change Log:
    - 1.0 Initial JSON validation helper
    - 1.1 Attempted TryParse fix
    - 1.2 Replace TryParse with PowerShell-native date validation
#>

param (
    [string]$JsonPath = '.\updates.json'
)

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

function Fail {
    param ([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    $script:HasErrors = $true
}

function Warn {
    param ([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

$HasErrors = $false

# ------------------------------------------------------------
# File existence
# ------------------------------------------------------------

if (-not (Test-Path $JsonPath)) {
    Fail "updates.json not found at path: $JsonPath"
    return
}

# ------------------------------------------------------------
# JSON syntax validation
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

if (-not $data.schema_version) {
    Fail "Missing top-level property: schema_version"
}

if (-not $data.last_updated) {
    Fail "Missing top-level property: last_updated"
}

if (-not $data.updates -or -not ($data.updates -is [System.Collections.IEnumerable])) {
    Fail "Missing or invalid 'updates' array"
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

$requiredUpdateFields = @(
    'id','name','vendor','category','current','source','install','upgrade','history'
)

foreach ($update in $data.updates) {

    foreach ($field in $requiredUpdateFields) {
        if (-not $update.$field) {
            Fail "Update '$($update.id)' missing required field: $field"
        }
    }

    # --- Current ---------------------------------------------------

    if (-not $update.current.version) {
        Fail "Update '$($update.id)' missing current.version"
    }

    if (-not $update.current.release_date) {
        Fail "Update '$($update.id)' missing current.release_date"
    }
    else {
        try {
            [void](Get-Date $update.current.release_date)
        }
        catch {
            Fail "Update '$($update.id)' has invalid current.release_date"
        }
    }

    # --- History ---------------------------------------------------

    if (-not $update.history -or $update.history.Count -eq 0) {
        Fail "Update '$($update.id)' has empty history array"
        continue
    }

    foreach ($h in $update.history) {

        foreach ($hf in @('version','release_date','noted_on')) {
            if (-not $h.$hf) {
                Fail "Update '$($update.id)' history entry missing field: $hf"
            }
        }

        foreach ($df in @('release_date','noted_on')) {
            if ($h.$df) {
                try {
                    [void](Get-Date $h.$df)
                }
                catch {
                    Fail "Update '$($update.id)' history has invalid date in $df"
                }
            }
        }
    }

    # --- Logical consistency --------------------------------------

    $latestHistory = $update.history | Select-Object -First 1

    if ($latestHistory.version -ne $update.current.version) {
        Warn "Update '$($update.id)' current.version does not match latest history entry"
    }

    if ($latestHistory.release_date -ne $update.current.release_date) {
        Warn "Update '$($update.id)' current.release_date does not match latest history entry"
    }
}

# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

Write-Host "----------------------------------------"

if ($HasErrors) {
    Write-Host "Validation FAILED" -ForegroundColor Red
}
else {
    Write-Host "Validation PASSED" -ForegroundColor Green
}


# Example Usage
# .\Test-UpdatesJson.ps1
