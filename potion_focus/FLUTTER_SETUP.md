# Flutter Setup Guide

## Quick Setup

### Option 1: Use the Setup Script (Easiest)

```powershell
cd c:\Users\jasme\Potions\potion_focus
.\setup_flutter.ps1
```

This script will:
- Find your Flutter installation
- Check Flutter setup
- Get project dependencies
- Generate required code
- Check for connected devices

### Option 2: Manual Setup

#### Step 1: Find Your Flutter Installation

Where did you download/extract Flutter? Common locations:
- `C:\src\flutter`
- `C:\flutter`
- `%USERPROFILE%\flutter`
- `%LOCALAPPDATA%\flutter`
- Or wherever you extracted it

#### Step 2: Add Flutter to PATH (Optional but Recommended)

1. **Find Flutter bin folder:**
   - If Flutter is at `C:\src\flutter`
   - Then bin folder is: `C:\src\flutter\bin`

2. **Add to PATH:**
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "User variables", select "Path" → Edit
   - Click "New" → Add: `C:\src\flutter\bin` (or your Flutter bin path)
   - Click OK on all dialogs
   - **Restart PowerShell/Terminal**

3. **Verify:**
   ```powershell
   flutter --version
   ```

#### Step 3: Initialize Project

If Flutter is in PATH:
```powershell
cd c:\Users\jasme\Potions\potion_focus
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

If Flutter is NOT in PATH (use full path):
```powershell
cd c:\Users\jasme\Potions\potion_focus
C:\path\to\flutter\bin\flutter.bat pub get
C:\path\to\flutter\bin\flutter.bat pub run build_runner build --delete-conflicting-outputs
```

#### Step 4: Check Setup

```powershell
flutter doctor
```

This shows what's installed and what's missing.

#### Step 5: Connect Android Device

1. **Enable Developer Options:**
   - Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect via USB:**
   - Connect phone to PC
   - Allow USB debugging when prompted

4. **Verify Connection:**
   ```powershell
   flutter devices
   ```
   Should show your Android device.

#### Step 6: Run the App

```powershell
flutter run
```

Or use the helper script:
```powershell
.\run_app.ps1
```

## Troubleshooting

### Flutter Not Found

**If you haven't downloaded Flutter yet:**
1. Download from: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\src\flutter` (or your preferred location)
3. Run setup script again

**If Flutter is downloaded but not found:**
1. Find where you extracted it
2. Run setup script and provide the path when asked
3. Or manually add to PATH (see Step 2 above)

### Flutter Doctor Issues

Common issues and fixes:

**Android toolchain missing:**
- Install Android Studio
- Or install Android SDK command-line tools

**VS Code/Android Studio not found:**
- Optional - you can use any editor
- Flutter works without them

**Device not detected:**
- Check USB cable (try different one)
- Check USB port (try different port)
- Restart ADB: `adb kill-server && adb start-server`
- Unlock phone screen

### Code Generation Errors

If `build_runner` fails:
```powershell
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Permission Errors

- Make sure USB Debugging is enabled
- Check phone screen is unlocked
- Try different USB cable/port

## Quick Commands Reference

```powershell
# Check Flutter version
flutter --version

# Check setup
flutter doctor

# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Check devices
flutter devices

# Run app
flutter run

# Build APK
flutter build apk

# Clean build
flutter clean
```

## Need Help?

1. Run the setup script: `.\setup_flutter.ps1`
2. Check Flutter doctor output
3. See INSTALL_ON_ANDROID.md for device setup
4. Check Flutter docs: https://flutter.dev/docs



