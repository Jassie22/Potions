# Flutter Setup Script for Potion Focus
# This script helps initialize Flutter for the project

Write-Host "Potion Focus - Flutter Setup" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Find Flutter
Write-Host "Step 1: Looking for Flutter..." -ForegroundColor Yellow

$flutterPaths = @(
    "C:\src\flutter\bin\flutter.bat",
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
    "$env:PROGRAMFILES\flutter\bin\flutter.bat",
    "$env:PROGRAMFILES(X86)\flutter\bin\flutter.bat"
)

$flutterPath = $null
foreach ($path in $flutterPaths) {
    if (Test-Path $path) {
        $flutterPath = $path
        Write-Host "Found Flutter at: $path" -ForegroundColor Green
        break
    }
}

if (-not $flutterPath) {
    Write-Host "Flutter not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide the path to your Flutter installation:" -ForegroundColor Yellow
    Write-Host "Example: C:\Users\YourName\Downloads\flutter\bin\flutter.bat" -ForegroundColor Gray
    $customPath = Read-Host "Enter Flutter path (or press Enter to search manually)"
    
    if ($customPath -and (Test-Path $customPath)) {
        $flutterPath = $customPath
        Write-Host "Using Flutter at: $flutterPath" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Let's search for flutter.bat in common directories..." -ForegroundColor Yellow
        $searchDirs = @("C:\", "$env:USERPROFILE", "$env:LOCALAPPDATA")
        
        foreach ($dir in $searchDirs) {
            Write-Host "Searching in $dir..." -ForegroundColor Gray
            $found = Get-ChildItem -Path $dir -Filter "flutter.bat" -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
            if ($found) {
                $flutterPath = $found.FullName
                Write-Host "Found Flutter at: $flutterPath" -ForegroundColor Green
                break
            }
        }
    }
}

if (-not $flutterPath) {
    Write-Host ""
    Write-Host "ERROR: Could not find Flutter!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter from: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extract it to a location like C:\src\flutter" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Get Flutter directory
$flutterDir = Split-Path (Split-Path $flutterPath -Parent) -Parent
$flutterBin = Join-Path $flutterDir "bin"

Write-Host ""
Write-Host "Flutter Directory: $flutterDir" -ForegroundColor Cyan
Write-Host ""

# Step 2: Check Flutter
Write-Host "Step 2: Checking Flutter installation..." -ForegroundColor Yellow
& $flutterPath --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter check failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Run Flutter Doctor
Write-Host ""
Write-Host "Step 3: Running Flutter Doctor..." -ForegroundColor Yellow
& $flutterPath doctor
Write-Host ""

# Step 4: Navigate to project
Write-Host "Step 4: Setting up project..." -ForegroundColor Yellow
$projectDir = $PSScriptRoot
Set-Location $projectDir
Write-Host "Project directory: $projectDir" -ForegroundColor Cyan

# Step 5: Get dependencies
Write-Host ""
Write-Host "Step 5: Getting Flutter dependencies..." -ForegroundColor Yellow
& $flutterPath pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies!" -ForegroundColor Red
    exit 1
}

# Step 6: Generate code
Write-Host ""
Write-Host "Step 6: Generating required code..." -ForegroundColor Yellow
Write-Host "This may take a minute..." -ForegroundColor Gray
& $flutterPath pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Code generation had issues, but continuing..." -ForegroundColor Yellow
}

# Step 7: Check devices
Write-Host ""
Write-Host "Step 7: Checking for connected devices..." -ForegroundColor Yellow
& $flutterPath devices
Write-Host ""

# Summary
Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Connect your Android device via USB" -ForegroundColor White
Write-Host "2. Enable USB Debugging on your phone" -ForegroundColor White
Write-Host "3. Run: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Or use the full path:" -ForegroundColor Gray
Write-Host "  & '$flutterPath' run" -ForegroundColor Gray
Write-Host ""

# Save Flutter path for future use
$flutterPathFile = Join-Path $projectDir ".flutter_path"
$flutterBin | Out-File -FilePath $flutterPathFile -Encoding UTF8
Write-Host "Flutter path saved to: .flutter_path" -ForegroundColor Gray
Write-Host "You can use: .\run_app.ps1 to run the app easily" -ForegroundColor Gray



