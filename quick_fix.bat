@echo off
echo Installing Android SDK 33 and building app...
echo.

if exist "C:\Users\user\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" (
    echo Using cmdline-tools...
    cd "C:\Users\user\AppData\Local\Android\Sdk\cmdline-tools\latest\bin"
    call sdkmanager.bat "platforms;android-33"
    call sdkmanager.bat "build-tools;33.0.0"
) else if exist "C:\Users\user\AppData\Local\Android\Sdk\tools\bin\sdkmanager.bat" (
    echo Using tools...
    cd "C:\Users\user\AppData\Local\Android\Sdk\tools\bin"
    call sdkmanager.bat "platforms;android-33"
    call sdkmanager.bat "build-tools;33.0.0"
) else (
    echo SDK Manager not found. Please install through Android Studio.
    echo Go to Tools → SDK Manager → Install Android 13.0 (API 33)
    pause
    exit /b 1
)

cd "C:\Users\user\Downloads\new 75\ecobuddy"
echo.
echo Cleaning and rebuilding...
flutter clean
flutter pub get
flutter build apk --release

echo.
echo Done! Check if build was successful.
pause