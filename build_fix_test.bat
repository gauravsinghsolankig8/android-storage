@echo off
echo Testing network connectivity fixes...
echo.

echo Step 1: Cleaning Flutter project...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Cleaning Android build...
cd android
call gradlew clean
cd ..

echo Step 4: Testing connectivity...
ping -n 1 repo.maven.apache.org
ping -n 1 repo1.maven.org

echo Step 5: Attempting release build...
flutter build apk --release

echo.
echo Build attempt completed!
echo If it still fails, try running: flutter build apk --debug
echo Or check the NETWORK_BUILD_FIX.md file for more solutions.
pause