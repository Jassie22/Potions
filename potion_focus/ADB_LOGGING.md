# ADB Logging for Error Tracking

## Quick Start

### Start Logging

```powershell
cd c:\Users\jasme\Potions\potion_focus
.\log_errors.ps1
```

This will:
- Start capturing Flutter/Dart errors
- Filter for relevant errors
- Save to `logs\app_errors_YYYYMMDD_HHMMSS.log`
- Display errors in real-time

## Manual ADB Logging Commands

### View All Logs (Live)

```powershell
# Find ADB (if Flutter is installed)
$flutterPath = where.exe flutter
$androidSdk = "$env:LOCALAPPDATA\Android\Sdk"
$adb = "$androidSdk\platform-tools\adb.exe"

# Or use Flutter's bundled ADB
flutter run
# This automatically shows logs in the terminal
```

### Filter Flutter/Dart Errors Only

```powershell
# Basic filtering
adb logcat | Select-String -Pattern "flutter|dart|potion_focus"

# Better filtering (save to file)
adb logcat | Select-String -Pattern "flutter|ERROR|Exception" | Tee-Object -FilePath "errors.log"
```

### Clear Log Buffer

```powershell
adb logcat -c
```

### Save Complete Logs

```powershell
adb logcat > complete_log.txt
```

### Filter by App Package

```powershell
adb logcat | Select-String -Pattern "com.example.potion_focus"
```

## PowerShell Script for Automatic Logging

I've created `log_errors.ps1` that handles this automatically.

### Usage:

```powershell
# Start logging (runs until you press Ctrl+C)
.\log_errors.ps1

# Or log to file only (no console output)
.\log_errors.ps1 -Quiet

# Specify custom log file
.\log_errors.ps1 -LogFile "my_logs.txt"
```

## Common Error Patterns to Watch For

### Database Errors
```
IsarException
DatabaseException
```

### State Management Errors
```
RiverpodException
ProviderNotFoundException
```

### Sync Errors
```
SupabaseException
SyncError
```

### General Dart Errors
```
Exception
Error
AssertionError
```

## Using Flutter's Built-in Logging

### During Development

When you run:
```powershell
flutter run
```

Flutter automatically shows:
- App logs
- Errors
- Hot reload status
- Debug output

Press `r` for hot reload, `R` for hot restart, `q` to quit.

### Production Logging

For release builds, you need to check device logs:

```powershell
adb logcat | Select-String -Pattern "flutter"
```

## Viewing Logs from Previous Sessions

If you saved logs to a file:

```powershell
# View errors only
Get-Content errors.log | Select-String -Pattern "ERROR|Exception"

# View last 50 lines
Get-Content errors.log -Tail 50

# Search for specific error
Get-Content errors.log | Select-String -Pattern "DatabaseException"
```

## Debugging Tips

### 1. Clear App Data Before Testing

```powershell
adb shell pm clear com.example.potion_focus
```

This resets the app to clean state.

### 2. Check App Permissions

```powershell
adb shell dumpsys package com.example.potion_focus | Select-String -Pattern "permission"
```

### 3. Monitor Memory Usage

```powershell
adb shell dumpsys meminfo com.example.potion_focus
```

### 4. Check Network Requests (Supabase)

```powershell
adb logcat | Select-String -Pattern "supabase|http"
```

## Troubleshooting ADB Issues

### ADB Not Found

If ADB isn't in PATH, find it:

```powershell
# Find Flutter installation
where.exe flutter

# ADB is usually here:
$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe

# Or Flutter bundles it:
$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

### Device Not Found

```powershell
# Check devices
adb devices

# If empty, restart ADB
adb kill-server
adb start-server
adb devices
```

### Permission Denied

```powershell
# Check if device is authorized
adb devices
# Should show "device" not "unauthorized"
```

---

**See INSTALL_ON_ANDROID.md for installation steps first!**



