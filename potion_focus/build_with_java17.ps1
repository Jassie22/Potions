# Build script with Java 17 configuration
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "C:\Program Files\Java\jdk-17\bin;$env:PATH"

Write-Host "Using Java 17: $env:JAVA_HOME" -ForegroundColor Green
java -version

Write-Host "`nBuilding Flutter app..." -ForegroundColor Cyan
& "C:\Users\jasme\Development\flutter\bin\flutter.bat" build apk --debug
