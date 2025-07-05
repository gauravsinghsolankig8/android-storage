# Network Build Fix Guide

## Problem Summary
Your Flutter app build is failing with network connectivity errors when Gradle tries to download dependencies from Maven repositories, specifically:
- `No such host is known (repo.maven.apache.org)`
- Failed to download `kotlin-compiler-embeddable-1.6.10.jar`
- The error is occurring in the `:rive_common` plugin

## Solutions (Try in order)

### Solution 1: Check Internet Connection
First, verify your basic connectivity:
```bash
ping repo.maven.apache.org
ping google.com
```

### Solution 2: Configure Gradle for Better Network Handling
Add these lines to your `android/gradle.properties`:
```properties
# Network timeout configurations
systemProp.http.connectionTimeout=600000
systemProp.http.socketTimeout=600000
systemProp.https.connectionTimeout=600000
systemProp.https.socketTimeout=600000

# DNS configuration
systemProp.java.net.preferIPv4Stack=true
systemProp.java.net.preferIPv6Addresses=false
```

### Solution 3: Use Alternative Maven Repositories
If you're in a region with restricted access to Maven Central, modify your `android/build.gradle`:

```gradle
allprojects {
    repositories {
        // Try these mirrors first
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://repo1.maven.org/maven2/' }
        
        // Original repositories as fallback
        google()
        mavenCentral()
    }
}
```

### Solution 4: Configure Proxy Settings (If behind corporate firewall)
If you're behind a corporate firewall, add proxy settings to `android/gradle.properties`:
```properties
systemProp.http.proxyHost=your.proxy.host
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=your.proxy.host
systemProp.https.proxyPort=8080
# Add these if your proxy requires authentication
systemProp.http.proxyUser=username
systemProp.http.proxyPassword=password
systemProp.https.proxyUser=username
systemProp.https.proxyPassword=password
```

### Solution 5: Force Gradle to Use IPv4
Add this to your `android/gradle.properties`:
```properties
systemProp.java.net.preferIPv4Stack=true
```

### Solution 6: Clean Build and Retry
Run these commands to clean your build:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter build apk --release
```

### Solution 7: Try Building in Debug Mode First
Sometimes debug builds work when release builds fail:
```bash
flutter build apk --debug
```

### Solution 8: Update Gradle Wrapper
Update your Gradle wrapper to the latest version:
```bash
cd android
./gradlew wrapper --gradle-version 8.5
```

### Solution 9: Disable Gradle Configuration Cache
Add this to your `android/gradle.properties`:
```properties
org.gradle.configuration-cache=false
org.gradle.configuration-cache.problems=warn
```

### Solution 10: Alternative Build Command
Try building with verbose output to see more details:
```bash
flutter build apk --release --verbose
```

## Rive-Specific Solutions

Since the error is specifically with the `rive_common` plugin, you can try:

### Option A: Update Rive Plugin
Update the Rive plugin to the latest version in your `pubspec.yaml`:
```yaml
dependencies:
  rive: ^0.13.20  # Latest version as of recent updates
```

### Option B: Remove Rive Temporarily
If you don't need Rive animations immediately, comment out the rive dependency:
```yaml
dependencies:
  # rive: ^0.12.4  # Temporarily disabled
```

Then run `flutter pub get` and try building again.

## DNS Resolution Fix

If you're having DNS issues, try these steps:

1. **Flush DNS Cache (Windows)**:
   ```cmd
   ipconfig /flushdns
   ```

2. **Use Google DNS**:
   - Go to Network Settings
   - Change DNS to 8.8.8.8 and 8.8.4.4

3. **Use Alternative DNS**:
   - Cloudflare DNS: 1.1.1.1 and 1.0.0.1

## Quick Fix Commands

Run these commands in sequence:
```bash
# Clean everything
flutter clean

# Update dependencies
flutter pub get

# Clean Android build
cd android
./gradlew clean
cd ..

# Try building again
flutter build apk --release
```

## If Nothing Works

1. **Try building on a different network** (mobile hotspot, different WiFi)
2. **Use a VPN** if you suspect regional restrictions
3. **Check Windows Defender/Antivirus** - sometimes they block Maven downloads
4. **Try building at a different time** - sometimes Maven Central has regional outages

## Monitoring the Fix

After applying any solution, monitor the build progress:
- The first build after clean might take longer
- Watch for different error messages
- If it progresses past the Rive plugin, the fix is working

## Success Indicators

You'll know it's working when you see:
- "Downloading kotlin-compiler-embeddable-1.6.10.jar" succeeds
- Build progresses past the ":rive_common" configuration
- New build errors (if any) are not network-related

Let me know which solution works for you!