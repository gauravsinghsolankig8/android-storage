@echo off
echo ================================
echo  Flutter Build Fix Test Script
echo ================================
echo.

echo Step 1: Checking Flutter project setup...
if not exist "pubspec.yaml" (
    echo Error: pubspec.yaml not found. Make sure you're in the project root.
    pause
    exit /b 1
)

echo Step 2: Cleaning Flutter project...
flutter clean

echo Step 3: Getting Flutter dependencies...
flutter pub get

echo Step 4: Cleaning Android build with new gradlew.bat...
cd android
if exist "gradlew.bat" (
    echo Using gradlew.bat...
    call gradlew.bat clean
) else (
    echo Error: gradlew.bat not found!
)
cd ..

echo Step 5: Testing basic connectivity...
ping -n 1 repo.maven.apache.org
ping -n 1 repo1.maven.org

echo Step 6: Running dart build_runner (if needed)...
dart run build_runner build --delete-conflicting-outputs

echo Step 7: Attempting debug build first...
flutter build apk --debug

echo Step 8: If debug succeeds, trying release build...
flutter build apk --release

echo.
echo ================================
echo Build test completed!
echo ================================
echo.
echo If errors persist:
echo 1. Check NETWORK_BUILD_FIX.md for more solutions
echo 2. Try building on a different network
echo 3. Check Windows Defender/Firewall settings
echo 4. Consider using a VPN if regional restrictions apply
echo.
pause