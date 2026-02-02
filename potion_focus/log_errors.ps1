# PowerShell script for ADB error logging
# Usage: .\log_errors.ps1 [options]

param(
    [switch]$Quiet,
    [string]$LogFile = "",
    [string]$Filter = "flutter|dart|ERROR|Exception|FATAL"
)

# Create logs directory if it doesn't exist
$logsDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Generate log filename if not provided
if ([string]::IsNullOrEmpty($LogFile)) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $LogFile = Join-Path $logsDir "app_errors_$timestamp.log"
}

Write-Host "Starting error logging..." -ForegroundColor Green
Write-Host "Log file: $LogFile" -ForegroundColor Cyan
Write-Host "Filter: $Filter" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Try to find ADB
$adb = $null

# Check common ADB locations
$possiblePaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe",
    "$env:ANDROID_HOME\platform-tools\adb.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $adb = $path
        break
    }
}

# Try to find ADB via Flutter
if (-not $adb) {
    try {
        $flutterPath = (Get-Command flutter -ErrorAction SilentlyContinue).Source
        if ($flutterPath) {
            $sdkPath = Join-Path (Split-Path (Split-Path $flutterPath)) "Android\Sdk\platform-tools\adb.exe"
            if (Test-Path $sdkPath) {
                $adb = $sdkPath
            }
        }
    } catch {
        # Flutter not found, continue
    }
}

# If still not found, check if it's in PATH
if (-not $adb) {
    try {
        $adbCheck = Get-Command adb -ErrorAction SilentlyContinue
        if ($adbCheck) {
            $adb = $adbCheck.Source
        }
    } catch {
        # ADB not in PATH
    }
}

if (-not $adb -or -not (Test-Path $adb)) {
    Write-Host "ERROR: ADB not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter or Android SDK first." -ForegroundColor Yellow
    Write-Host "See INSTALL_ON_ANDROID.md for instructions." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or find ADB manually and update this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "Using ADB: $adb" -ForegroundColor Gray
Write-Host ""

# Check if device is connected
$deviceCheck = & $adb devices 2>&1
$devices = ($deviceCheck | Select-String "device$" | Measure-Object).Count

if ($devices -eq 0) {
    Write-Host "WARNING: No Android devices detected!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Connect your Android device via USB" -ForegroundColor Yellow
    Write-Host "2. Enable USB Debugging in Developer Options" -ForegroundColor Yellow
    Write-Host "3. Run 'adb devices' to verify connection" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Continuing anyway (may not capture logs)..." -ForegroundColor Yellow
    Write-Host ""
}

# Clear log buffer
& $adb logcat -c 2>&1 | Out-Null

Write-Host "Starting log capture..." -ForegroundColor Green
Write-Host ""

# Start logcat with filtering
if ($Quiet) {
    # Only write to file, no console output
    & $adb logcat 2>&1 | Select-String -Pattern $Filter | Tee-Object -FilePath $LogFile
} else {
    # Write to both console and file
    & $adb logcat 2>&1 | Select-String -Pattern $Filter | Tee-Object -FilePath $LogFile
}



