<#
.SYNOPSIS
    One-time setup for SmartSpend on a new Windows machine.
    Run this once after cloning the repo, then use .\scripts\start.ps1 to run the app.

.NOTES
    Run from the repository root:  .\scripts\setup.ps1
    Prerequisites: Docker Desktop installed and running, Flutter SDK on PATH.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$missing  = $false

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  SmartSpend - New Machine Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# --- Check: Docker -----------------------------------------------------------
Write-Host ">> Checking prerequisites..." -ForegroundColor Cyan

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  [MISSING] Docker Desktop is not installed or not on PATH." -ForegroundColor Red
    Write-Host "  Download it from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host ""
    $missing = $true
} else {
    $dockerVersion = (docker --version)
    Write-Host "  [OK] Docker: $dockerVersion" -ForegroundColor Green
}

# --- Check: Flutter ----------------------------------------------------------
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  [MISSING] Flutter SDK is not installed or not on PATH." -ForegroundColor Red
    Write-Host "  Download it from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host ""
    $missing = $true
} else {
    $flutterVersion = (flutter --version 2>&1 | Select-Object -First 1)
    Write-Host "  [OK] Flutter: $flutterVersion" -ForegroundColor Green
}

# --- Check: Git --------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  [MISSING] Git is not installed or not on PATH." -ForegroundColor Red
    Write-Host "  Download it from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    $missing = $true
} else {
    $gitVersion = (git --version)
    Write-Host "  [OK] Git: $gitVersion" -ForegroundColor Green
}

if ($missing) {
    Write-Host ""
    Write-Host "ERROR: Install the missing tools above, then re-run this script." -ForegroundColor Red
    exit 1
}

# --- Copy .env ---------------------------------------------------------------
Write-Host ""
Write-Host ">> Checking .env file..." -ForegroundColor Cyan

$envFile    = Join-Path $repoRoot ".env"
$envExample = Join-Path $repoRoot ".env.example"

if (Test-Path $envFile) {
    Write-Host "  [OK] .env already exists - skipping copy." -ForegroundColor Green
} else {
    Copy-Item $envExample $envFile
    Write-Host "  [CREATED] .env copied from .env.example" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  *** ACTION REQUIRED ***" -ForegroundColor Yellow
    Write-Host "  Open .env and replace all CHANGE_ME values before running the app." -ForegroundColor Yellow
    Write-Host "  Especially set a strong JWT_SECRET." -ForegroundColor Yellow
}

# --- Flutter pub get ---------------------------------------------------------
Write-Host ""
Write-Host ">> Fetching Flutter dependencies..." -ForegroundColor Cyan
Push-Location $repoRoot
try {
    flutter pub get
} finally {
    Pop-Location
}

# --- Done --------------------------------------------------------------------
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Edit .env and replace any CHANGE_ME values" -ForegroundColor White
Write-Host "    2. Make sure Docker Desktop is running" -ForegroundColor White
Write-Host "    3. Run:  .\scripts\start.ps1" -ForegroundColor Cyan
Write-Host ""
