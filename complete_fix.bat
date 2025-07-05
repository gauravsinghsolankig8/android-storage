@echo off
echo ================================
echo  Complete Build Fix Script
echo ================================

echo Step 1: Complete cleanup...
flutter clean
flutter pub clean
cd android
if exist gradlew.bat (
    call gradlew.bat clean
)
if exist .gradle (
    rd /s /q .gradle
)
if exist build (
    rd /s /q build
)
cd ..
if exist build (
    rd /s /q build
)

echo Step 2: Checking SDK availability...
if exist "C:\Users\user\AppData\Local\Android\Sdk\platforms\android-34" (
    echo ✓ Android 34 available - using SDK 34
    set TARGET_SDK=34
) else if exist "C:\Users\user\AppData\Local\Android\Sdk\platforms\android-33" (
    echo ✓ Android 33 available - using SDK 33
    set TARGET_SDK=33
) else (
    echo ❌ Neither Android 33 nor 34 found
    echo Attempting to install Android SDK 33...
    if exist "C:\Users\user\AppData\Local\Android\Sdk\tools\bin\sdkmanager.bat" (
        cd "C:\Users\user\AppData\Local\Android\Sdk\tools\bin"
        call sdkmanager.bat "platforms;android-33"
        call sdkmanager.bat "build-tools;33.0.0"
        cd "C:\Users\user\Downloads\new 75\ecobuddy"
        set TARGET_SDK=33
        echo ✓ Android SDK 33 installed
    ) else (
        echo Please install Android SDK 33 or 34 through Android Studio
        pause
        exit /b 1
    )
)

echo Step 3: Getting dependencies...
flutter pub get

echo Step 4: Building...
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo ✓ Debug build successful!
    flutter build apk --release
    if %ERRORLEVEL% EQU 0 (
        echo 🎉 SUCCESS! Release build completed!
    ) else (
        echo ⚠️ Release build failed, but debug APK is available
    )
) else (
    echo ❌ Build failed. Check error messages above.
)

pause