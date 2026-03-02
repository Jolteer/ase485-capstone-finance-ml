<#
.SYNOPSIS
    Starts the full SmartSpend dev stack: PostgreSQL + FastAPI + pgAdmin via
    Docker Compose, waits for the API to become healthy, then launches the
    Flutter app.

.PARAMETER Device
    Optional Flutter device id (e.g. chrome, windows, edge).
    Passed as "flutter run -d <Device>". If omitted Flutter will prompt
    when multiple devices are available.

.NOTES
    Run from the repository root:  .\scripts\start.ps1
                              or:  .\scripts\start.ps1 -Device chrome
    Prerequisites: Docker Desktop running, Flutter SDK on PATH.
#>
param(
    [string]$Device
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

# --- Pre-flight checks -----------------------------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'docker' not found. Make sure Docker Desktop is installed and running." -ForegroundColor Red
    exit 1
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'flutter' not found. Make sure the Flutter SDK is on your PATH." -ForegroundColor Red
    exit 1
}

# --- Start Docker Compose ---------------------------------------------------
Write-Host "`n>> Starting Docker Compose services (db, backend, pgadmin)..." -ForegroundColor Cyan
docker compose -f "$repoRoot\docker-compose.yml" up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: docker compose up failed." -ForegroundColor Red
    exit 1
}

# --- Wait for the API -------------------------------------------------------
$apiUrl     = 'http://localhost:8000/health'
$maxRetries = 20
$retryDelay = 2

Write-Host ">> Waiting for API at $apiUrl ..." -ForegroundColor Cyan
for ($i = 1; $i -le $maxRetries; $i++) {
    try {
        $response = Invoke-WebRequest -Uri $apiUrl -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host "   API is ready." -ForegroundColor Green
            break
        }
    } catch {
        # Ignore connection errors while the container is starting.
    }

    if ($i -eq $maxRetries) {
        $totalWait = $maxRetries * $retryDelay
        Write-Host "ERROR: API did not become healthy after ${totalWait}s. Check 'docker compose logs backend'." -ForegroundColor Red
        exit 1
    }

    Write-Host "   Attempt $i/$maxRetries - retrying in ${retryDelay}s..."
    Start-Sleep -Seconds $retryDelay
}

# --- Launch Flutter ----------------------------------------------------------
Write-Host "`n>> Installing Flutter dependencies..." -ForegroundColor Cyan
Push-Location $repoRoot
try {
    flutter pub get
    Write-Host "`n>> Launching Flutter app..." -ForegroundColor Cyan
    if ($Device) {
        flutter run -d $Device
    } else {
        flutter run
    }
} finally {
    Pop-Location
}
