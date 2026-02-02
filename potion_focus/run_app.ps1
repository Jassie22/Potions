# Quick script to run Potion Focus app
# Uses saved Flutter path or searches for it

$projectDir = $PSScriptRoot
Set-Location $projectDir

# Try to load saved Flutter path
$flutterPathFile = Join-Path $projectDir ".flutter_path"
$flutterBin = $null

if (Test-Path $flutterPathFile) {
    $flutterBin = Get-Content $flutterPathFile -Raw | ForEach-Object { $_.Trim() }
    $flutterPath = Join-Path $flutterBin "flutter.bat"
    
    if (Test-Path $flutterPath) {
        Write-Host "Using saved Flutter path: $flutterPath" -ForegroundColor Green
    } else {
        $flutterBin = $null
    }
}

# If not found, search
if (-not $flutterBin) {
    Write-Host "Searching for Flutter..." -ForegroundColor Yellow
    
    $flutterPaths = @(
        "C:\src\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat"
    )
    
    foreach ($path in $flutterPaths) {
        if (Test-Path $path) {
            $flutterPath = $path
            $flutterBin = Split-Path (Split-Path $path -Parent) -Parent
            break
        }
    }
}

if (-not $flutterPath -or -not (Test-Path $flutterPath)) {
    Write-Host "ERROR: Flutter not found!" -ForegroundColor Red
    Write-Host "Please run: .\setup_flutter.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Run the app
Write-Host "Running Potion Focus..." -ForegroundColor Cyan
Write-Host ""
& $flutterPath run



