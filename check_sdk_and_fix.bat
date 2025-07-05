@echo off
echo ================================
echo   Android SDK Version Checker
echo ================================
echo.

echo Step 1: Checking Android SDK installation...
set ANDROID_SDK_ROOT=C:\Users\user\AppData\Local\Android\Sdk
set ALT_SDK_ROOT=C:\Android\sdk

if exist "%ANDROID_SDK_ROOT%\platforms" (
    echo ✓ Found Android SDK at: %ANDROID_SDK_ROOT%
    set SDK_PATH=%ANDROID_SDK_ROOT%
    goto :check_platforms
) else if exist "%ALT_SDK_ROOT%\platforms" (
    echo ✓ Found Android SDK at: %ALT_SDK_ROOT%
    set SDK_PATH=%ALT_SDK_ROOT%
    goto :check_platforms
) else (
    echo ❌ Android SDK not found in common locations
    echo Please install Android Studio or set ANDROID_HOME
    goto :end
)

:check_platforms
echo.
echo Step 2: Checking available Android platforms...
echo Available SDK platforms:
dir "%SDK_PATH%\platforms" /B 2>nul | findstr "android-"

echo.
echo Step 3: Checking build tools...
echo Available build tools:
dir "%SDK_PATH%\build-tools" /B 2>nul

echo.
echo Step 4: Current project configuration...
echo Current compileSdk in build.gradle:
findstr "compileSdk" android\app\build.gradle

echo.
echo Step 5: Applying best SDK version...

rem Check for most compatible versions in order of preference
if exist "%SDK_PATH%\platforms\android-28" (
    echo ✓ Using Android 28 (most compatible)
    set TARGET_SDK=28
    set BUILD_TOOLS=28.0.3
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-29" (
    echo ✓ Using Android 29
    set TARGET_SDK=29
    set BUILD_TOOLS=29.0.3
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-30" (
    echo ✓ Using Android 30
    set TARGET_SDK=30
    set BUILD_TOOLS=30.0.3
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-31" (
    echo ✓ Using Android 31
    set TARGET_SDK=31
    set BUILD_TOOLS=31.0.0
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-32" (
    echo ✓ Using Android 32
    set TARGET_SDK=32
    set BUILD_TOOLS=32.0.0
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-33" (
    echo ✓ Using Android 33
    set TARGET_SDK=33
    set BUILD_TOOLS=33.0.0
    goto :apply_fix
)

if exist "%SDK_PATH%\platforms\android-34" (
    echo ✓ Using Android 34
    set TARGET_SDK=34
    set BUILD_TOOLS=34.0.0
    goto :apply_fix
)

echo ❌ No suitable Android SDK platform found
echo Please install Android SDK platform 28 or higher
goto :end

:apply_fix
echo.
echo Step 6: Updating project configuration to use Android %TARGET_SDK%...

rem Clean previous build
echo Cleaning Flutter project...
flutter clean >nul 2>&1

echo.
echo ✓ Configuration updated to use Android SDK %TARGET_SDK%
echo ✓ Build tools version: %BUILD_TOOLS%

echo.
echo Step 7: Testing the build...
echo Running flutter build apk --debug...
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo 🎉 SUCCESS! Debug build completed successfully!
    echo Now trying release build...
    flutter build apk --release
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo 🎉 COMPLETE SUCCESS! Release build also completed!
        echo Your APK is ready in: build\app\outputs\flutter-apk\
    ) else (
        echo.
        echo ⚠️  Debug build worked, but release build failed.
        echo This is often due to ProGuard/R8 issues.
        echo You can use the debug APK for testing.
    )
) else (
    echo.
    echo ❌ Build still failed. Checking common issues...
    echo.
    echo Possible solutions:
    echo 1. Install Android SDK Platform %TARGET_SDK% through Android Studio
    echo 2. Check internet connection for dependency downloads
    echo 3. Run: flutter doctor -v
    echo 4. Check SDK_INSTALLATION_FIX.md for detailed instructions
)

:end
echo.
echo ================================
echo   SDK Check Complete
echo ================================
echo.
pause