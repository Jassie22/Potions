# Script to find Java 17 installation
Write-Host "Searching for Java 17 installations..." -ForegroundColor Cyan

$searchPaths = @(
    "C:\Program Files\Java",
    "C:\Program Files (x86)\Java",
    "$env:USERPROFILE\AppData\Local\Programs",
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Microsoft",
    "$env:USERPROFILE"
)

$java17Paths = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Write-Host "Checking: $path" -ForegroundColor Gray
        $jdkDirs = Get-ChildItem -Path $path -Filter "*jdk*17*" -Directory -ErrorAction SilentlyContinue
        $jreDirs = Get-ChildItem -Path $path -Filter "*jre*17*" -Directory -ErrorAction SilentlyContinue
        
        foreach ($dir in $jdkDirs) {
            $javaExe = Join-Path $dir.FullName "bin\java.exe"
            if (Test-Path $javaExe) {
                $version = & $javaExe -version 2>&1 | Select-String "version"
                if ($version -match "17") {
                    Write-Host "Found Java 17: $($dir.FullName)" -ForegroundColor Green
                    $java17Paths += $dir.FullName
                }
            }
        }
        
        foreach ($dir in $jreDirs) {
            $javaExe = Join-Path $dir.FullName "bin\java.exe"
            if (Test-Path $javaExe) {
                $version = & $javaExe -version 2>&1 | Select-String "version"
                if ($version -match "17") {
                    Write-Host "Found Java 17: $($dir.FullName)" -ForegroundColor Green
                    $java17Paths += $dir.FullName
                }
            }
        }
    }
}

if ($java17Paths.Count -eq 0) {
    Write-Host "`nJava 17 not found in common locations." -ForegroundColor Yellow
    Write-Host "Please provide the path to your Java 17 installation." -ForegroundColor Yellow
} else {
    Write-Host "`nFound $($java17Paths.Count) Java 17 installation(s):" -ForegroundColor Cyan
    for ($i = 0; $i -lt $java17Paths.Count; $i++) {
        Write-Host "[$i] $($java17Paths[$i])" -ForegroundColor White
    }
}



