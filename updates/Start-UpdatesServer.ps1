<#
  File: Start-UpdatesServer.ps1
  Project: Updates Tracker
  Author: Jason Lamb
  Created Date: 2026-02-02
  Modified Date: 2026-02-02
  Revision: 1.1
  Change Log:
    - 1.0 Initial local server launcher
    - 1.1 Automatically open Updates UI in Google Chrome
#>

param (
    [int]$Port = 8000
)

# --- Validate Python ------------------------------------------------

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    throw 'Python is not installed or not in PATH'
}

# --- Start HTTP server ----------------------------------------------

Write-Host "Starting Updates Tracker server on port $Port..." -ForegroundColor Green

Start-Process python `
    -ArgumentList "-m http.server $Port" `
    -WorkingDirectory (Get-Location)

# --- Give server a moment to start ----------------------------------

Start-Sleep -Seconds 1

# --- Build URL ------------------------------------------------------

$url = "http://localhost:$Port/index.html"

Write-Host "Opening $url in Google Chrome..." -ForegroundColor Cyan

# --- Launch Chrome explicitly ---------------------------------------

$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
)

$chrome = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($chrome) {
    Start-Process $chrome $url
}
else {
    Write-Warning 'Google Chrome not found. Opening default browser instead.'
    Invoke-Item $url
}
