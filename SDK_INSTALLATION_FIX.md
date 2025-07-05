# Android SDK Platform 33 Installation Fix

## Problem
`Failed to find Platform SDK with path: platforms;android-33`

This error means Android SDK Platform 33 is not installed on your system.

## Solutions (Choose One)

### Solution 1: Install Android SDK Platform 33 (Recommended)

#### Option A: Using Android Studio
1. **Open Android Studio**
2. **Go to**: File → Settings → Appearance & Behavior → System Settings → Android SDK
3. **SDK Platforms tab**: Check "Android 13.0 (Tiramisu) API Level 33"
4. **SDK Tools tab**: Ensure these are installed:
   - Android SDK Build-Tools 33.0.0
   - Android SDK Platform-Tools
   - Android SDK Tools
5. **Click "Apply"** and let it download

#### Option B: Using Command Line (if you have Android SDK tools)
```cmd
cd %ANDROID_HOME%\tools\bin
sdkmanager "platforms;android-33"
sdkmanager "build-tools;33.0.0"
```

#### Option C: Using Flutter Doctor
```cmd
flutter doctor --android-licenses
flutter doctor
```

### Solution 2: Use Available SDK Version

#### Step 1: Check Available SDK Versions
Check what's installed in: `C:\Users\user\AppData\Local\Android\Sdk\platforms\`

Common versions:
- android-28 (API 28)
- android-29 (API 29) 
- android-30 (API 30)
- android-31 (API 31)
- android-32 (API 32)
- android-34 (API 34)

#### Step 2: Update Project to Use Available Version
If you have Android 34 (most common), update these files:

**File 1: `android/app/build.gradle`**
```gradle
android {
    namespace "com.echobuddy.app"
    compileSdk 34  // Change this

    defaultConfig {
        applicationId "com.echobuddy.app"
        minSdkVersion 21
        targetSdkVersion 34  // Change this
        // ... rest of config
    }
}
```

**File 2: `android/gradle.properties`**
```properties
android.compileSdkVersion=34
android.targetSdkVersion=34
android.buildToolsVersion=34.0.0
```

### Solution 3: Use Minimum SDK Version (Safest)

Change to Android 28 (most compatible):

**File 1: `android/app/build.gradle`**
```gradle
android {
    namespace "com.echobuddy.app"
    compileSdk 28

    defaultConfig {
        applicationId "com.echobuddy.app"
        minSdkVersion 21
        targetSdkVersion 28
        // ... rest of config
    }
}
```

**File 2: `android/gradle.properties`**
```properties
android.compileSdkVersion=28
android.targetSdkVersion=28
android.buildToolsVersion=28.0.3
```

## Quick Fix Commands

### For Android 34 (Most Likely Available)
```cmd
rem Update to SDK 34
cd android
echo compileSdk 34 > temp_sdk.txt
cd ..
```

### For Android 28 (Most Compatible)
```cmd
rem Update to SDK 28
cd android
echo compileSdk 28 > temp_sdk.txt
cd ..
```

## Verification Steps

1. **Check Available SDKs:**
   ```cmd
   dir "C:\Users\user\AppData\Local\Android\Sdk\platforms\"
   ```

2. **Check Build Tools:**
   ```cmd
   dir "C:\Users\user\AppData\Local\Android\Sdk\build-tools\"
   ```

3. **Run Flutter Doctor:**
   ```cmd
   flutter doctor -v
   ```

## Installation Paths

### Default Android SDK Locations:
- Windows: `C:\Users\%USERNAME%\AppData\Local\Android\Sdk`
- Alternative: `C:\Android\sdk`

### Required Components:
- Android SDK Platform (android-XX)
- Android SDK Build-Tools (XX.0.0)
- Android SDK Platform-Tools
- Android Emulator (optional)

## Troubleshooting

### If Android Studio is Not Installed:
1. **Download Android Studio**: https://developer.android.com/studio
2. **Install with default settings**
3. **Run initial setup** to download SDK components

### If Using Visual Studio Code Only:
1. **Install Android SDK manually**
2. **Set ANDROID_HOME environment variable**
3. **Add SDK tools to PATH**

### Environment Variables Check:
```cmd
echo %ANDROID_HOME%
echo %PATH%
```

Should show Android SDK path.

## Success Indicators

✅ `flutter doctor` shows no Android issues
✅ `dir "C:\Users\user\AppData\Local\Android\Sdk\platforms\"` shows android-XX folder
✅ Build progresses past the SDK error
✅ New error messages (if any) are not SDK-related

## Common SDK Versions and Compatibility

| SDK Version | Android Version | Compatibility |
|-------------|-----------------|---------------|
| 28          | Android 9.0     | High          |
| 29          | Android 10      | High          |
| 30          | Android 11      | Good          |
| 31          | Android 12      | Good          |
| 32          | Android 12L     | Medium        |
| 33          | Android 13      | Medium        |
| 34          | Android 14      | Latest        |

**Recommendation**: Use SDK 28 or 29 for maximum compatibility, or SDK 34 if you have the latest tools.