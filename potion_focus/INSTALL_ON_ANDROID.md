# Installing Potion Focus on Android Device

## Prerequisites

### 1. Install Flutter

Download and install Flutter from: https://flutter.dev/docs/get-started/install/windows

**Quick Steps:**
1. Download Flutter SDK
2. Extract to `C:\src\flutter` (or your preferred location)
3. Add Flutter to PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\src\flutter\bin`
4. Restart terminal/PowerShell

**Verify Installation:**
```powershell
flutter doctor
```

### 2. Enable USB Debugging on Android

1. **Enable Developer Options:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
   - Enable "Install via USB" (if available)

3. **Connect Phone:**
   - Connect phone to PC via USB cable
   - On phone, when prompted, tap "Allow USB Debugging"
   - Check "Always allow from this computer"
   - Tap "OK"

## Building and Installing the App

### Step 1: Navigate to Project

```powershell
cd c:\Users\jasme\Potions\potion_focus
```

### Step 2: Get Dependencies

```powershell
flutter pub get
```

### Step 3: Generate Required Code

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Check Connected Devices

```powershell
flutter devices
```

You should see your Android device listed like:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
```

### Step 5: Build and Install

```powershell
flutter install
```

Or to run directly:

```powershell
flutter run
```

This will:
- Build the APK
- Install on your connected device
- Launch the app
- Enable hot reload for development

## Alternative: Build APK Manually

If you want to build an APK file:

### Debug APK (for testing)

```powershell
flutter build apk --debug
```

The APK will be at: `build\app\outputs\flutter-apk\app-debug.apk`

You can then:
1. Copy to your phone
2. Install manually (enable "Install from Unknown Sources" first)

### Release APK (for distribution)

```powershell
flutter build apk --release
```

The APK will be at: `build\app\outputs\flutter-apk\app-release.apk`

## Troubleshooting

### Device Not Detected

1. **Check USB Connection:**
   ```powershell
   flutter devices
   ```

2. **Check ADB directly:**
   ```powershell
   # Find Flutter's ADB (usually in Android SDK)
   $env:ANDROID_HOME\platform-tools\adb.exe devices
   ```

3. **Restart ADB:**
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

### Build Errors

If you get build errors:

1. **Clean build:**
   ```powershell
   flutter clean
   flutter pub get
   ```

2. **Check for missing dependencies:**
   ```powershell
   flutter doctor
   ```

3. **Ensure code generation ran:**
   ```powershell
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Permission Errors on Android

- Check USB debugging is enabled
- Try different USB cable
- Try different USB port
- Unlock your phone screen while connecting

## First Run Setup

After installing:

1. **On first launch:**
   - Complete onboarding flow
   - Grant any necessary permissions (notifications, etc.)

2. **Test the app:**
   - Start a focus session
   - Complete it to create your first potion
   - Check Cabinet to see your collection
   - Verify quests are generated

---

**Once installed, see ADB_LOGGING.md for error tracking!**



