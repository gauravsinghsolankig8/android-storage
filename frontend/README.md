# Saranam Frontend

React Native mobile application built with Expo for the Saranam - Vrindavan Spiritual Guide App.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server
npx expo start
```

## 📋 Prerequisites

- Node.js (v16 or higher)
- Expo CLI
- iOS Simulator / Android Emulator
- React Native development environment

## 📱 Features

### Core Screens
- **Splash Screen**: Branded loading screen with animations
- **Onboarding**: Feature introduction with smooth transitions
- **Authentication**: Multiple login options (Email, Google, Phone OTP)
- **Home**: Interactive map with nearby spiritual locations
- **Temples**: Comprehensive temple listings with search and filters
- **Saints**: Profiles of past and present spiritual leaders
- **Events**: Upcoming festivals and celebrations
- **Parikrama**: Guided spiritual walking routes
- **Hotels**: Accommodation options with ratings
- **Store**: Spiritual items shopping with cart
- **Profile**: User settings, favorites, and preferences

### Key Features
- **Dark Mode**: Complete theme switching
- **Offline Support**: Cached data for offline viewing
- **Push Notifications**: Event reminders and updates
- **Location Services**: GPS-based discovery
- **Image Galleries**: High-quality temple and saint images
- **Search & Filters**: Advanced content discovery
- **Favorites System**: Save temples, saints, and events
- **Badge System**: Achievement tracking

## 🏗️ Architecture

### Tech Stack
- **React Native**: Cross-platform mobile development
- **Expo SDK 49**: Development platform and tools
- **React Navigation v6**: Navigation with bottom tabs
- **React Context**: State management
- **React Native Paper**: Material Design components
- **React Native Maps**: Location and mapping services
- **AsyncStorage**: Local data persistence

### Project Structure
```
frontend/
├── src/
│   ├── components/     # Reusable UI components
│   ├── context/        # React Context providers
│   ├── screens/        # Screen components
│   ├── services/       # API service layer
│   └── theme/          # Theme and styling
├── assets/             # Images, fonts, and static files
├── App.js              # Main app component
└── package.json        # Dependencies and scripts
```

## 🎨 Design System

### Theme
- **Light Mode**: Clean, bright interface
- **Dark Mode**: Easy on the eyes for evening use
- **Colors**: Spiritual theme with primary blues
- **Typography**: Roboto font family
- **Icons**: Ionicons for consistency
- **Spacing**: 8px grid system

### Components
- **Material Design 3**: Modern UI components
- **Custom Components**: PhoneAuthModal, ImageViewer
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: High contrast and readable fonts

## 🔧 Configuration

### App Configuration (app.json)
```json
{
  "expo": {
    "name": "Saranam - Vrindavan Spiritual Guide",
    "slug": "saranam-vrindavan",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#2c3e50"
    }
  }
}
```

### API Configuration
Update the API base URL in `src/services/api.js`:
```javascript
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:3000/api' 
  : 'https://your-production-api.com/api';
```

## 📱 Screen Details

### Authentication Flow
1. **Splash Screen**: Animated logo and loading
2. **Onboarding**: 6 slides introducing app features
3. **Login Options**: Email, Google, Phone OTP
4. **Phone Auth Modal**: OTP verification with Twilio

### Main Navigation
- **Home**: Map view with markers for temples, events, hotels
- **Temples**: List/grid view with search and filters
- **Saints**: Current and past saints with profiles
- **Events**: Upcoming festivals with details
- **Parikrama**: Route maps with progress tracking
- **Hotels**: Accommodation with ratings and booking
- **Store**: Product catalog with cart functionality
- **Profile**: User settings, favorites, and badges

### Detail Screens
- **Temple Detail**: Images, history, timings, rituals, nearby temples
- **Saint Detail**: Biography, teachings, schedule, related events
- **Event Detail**: Dates, descriptions, dos/don'ts, best temples
- **Product Detail**: Images, description, price, add to cart

## 🔌 API Integration

### Service Layer
The app uses a centralized API service layer:
- **authAPI**: Authentication endpoints
- **templesAPI**: Temple data and favorites
- **saintsAPI**: Saint profiles and information
- **eventsAPI**: Event details and schedules
- **parikramaAPI**: Route data and progress
- **hotelsAPI**: Hotel listings and ratings
- **storeAPI**: Product catalog and orders
- **darshanAPI**: Daily temple images
- **userAPI**: Profile and settings
- **notificationsAPI**: Push notifications

### State Management
- **AuthContext**: User authentication state
- **ThemeContext**: Dark/light mode preferences
- **Local Storage**: AsyncStorage for persistence

## 🎯 Key Components

### PhoneAuthModal
- Multi-step OTP verification
- Phone number input with country codes
- OTP input with auto-focus
- Name collection for new users

### ImageViewer
- Full-screen image gallery
- Swipe gestures for navigation
- Zoom and pan functionality
- Caption display

### Map Integration
- React Native Maps with Google provider
- Custom markers for different location types
- User location tracking
- Nearby location discovery

## 🚀 Development

### Scripts
```bash
npm start          # Start Expo development server
npm run android    # Run on Android emulator
npm run ios        # Run on iOS simulator
npm run web        # Run in web browser
```

### Development Workflow
1. Start Expo development server
2. Scan QR code with Expo Go app
3. Make changes and see live reload
4. Test on different devices and screen sizes
5. Use React Native Debugger for debugging

### Testing
```bash
# Run tests (when implemented)
npm test

# Run with coverage
npm run test:coverage
```

## 📦 Dependencies

### Core Dependencies
- **expo**: Expo SDK and tools
- **react**: React library
- **react-native**: React Native framework
- **@react-navigation/native**: Navigation library
- **react-native-paper**: Material Design components
- **react-native-maps**: Maps and location services
- **axios**: HTTP client for API calls
- **@react-native-async-storage/async-storage**: Local storage

### UI/UX Dependencies
- **react-native-vector-icons**: Icon library
- **react-native-image-zoom-viewer**: Image gallery
- **react-native-phone-number-input**: Phone input
- **react-native-otp-inputs**: OTP input
- **react-native-google-signin**: Google authentication
- **react-native-flash-message**: Toast notifications

### Utility Dependencies
- **expo-location**: Location services
- **expo-camera**: Camera functionality
- **expo-image-picker**: Image selection
- **expo-notifications**: Push notifications
- **expo-font**: Custom fonts
- **expo-splash-screen**: Splash screen management

## 🎨 Styling

### Theme System
```javascript
// Light theme
export const lightTheme = {
  colors: {
    primary: '#2c3e50',
    accent: '#3498db',
    background: '#ffffff',
    surface: '#f8f9fa',
    text: '#2c3e50',
    // ... more colors
  }
};

// Dark theme
export const darkTheme = {
  colors: {
    primary: '#3498db',
    background: '#1a1a1a',
    surface: '#2d2d2d',
    text: '#ffffff',
    // ... more colors
  }
};
```

### Component Styling
- **StyleSheet**: React Native StyleSheet for performance
- **Theme Integration**: All components use theme colors
- **Responsive Design**: Flexible layouts for different screens
- **Accessibility**: High contrast and readable fonts

## 🔒 Security

### Authentication
- JWT token storage in AsyncStorage
- Secure token refresh mechanism
- Biometric authentication (future)
- Session management

### Data Protection
- Encrypted local storage
- Secure API communication
- Input validation and sanitization
- Error handling without sensitive data exposure

## 📱 Platform Support

### iOS
- iOS 11.0 and above
- iPhone and iPad support
- iOS-specific features (Face ID, Touch ID)
- App Store optimization

### Android
- Android 6.0 (API level 23) and above
- Phone and tablet support
- Android-specific features (fingerprint)
- Google Play Store optimization

## 🚀 Deployment

### Development
- Expo Go app for testing
- Live reload and hot reloading
- Remote debugging support
- Device testing on real devices

### Production
- EAS Build for app store builds
- iOS App Store submission
- Google Play Store submission
- Over-the-air updates with Expo Updates

### Build Process
```bash
# Install EAS CLI
npm install -g @expo/eas-cli

# Configure EAS
eas build:configure

# Build for iOS
eas build --platform ios

# Build for Android
eas build --platform android
```

## 🐛 Troubleshooting

### Common Issues
- **Metro bundler issues**: Clear cache with `npx expo start -c`
- **iOS simulator not starting**: Check Xcode installation
- **Android emulator issues**: Verify Android Studio setup
- **API connection failed**: Check network and API URL

### Debugging
- Use React Native Debugger
- Enable remote debugging in Expo Go
- Check console logs for errors
- Use Flipper for advanced debugging

## 📈 Performance

### Optimization
- Image optimization and lazy loading
- FlatList for efficient list rendering
- Memoization for expensive calculations
- Bundle size optimization

### Monitoring
- Performance monitoring with Flipper
- Memory usage tracking
- Network request monitoring
- Crash reporting (future)

## 🔄 Updates

### Over-the-Air Updates
- Expo Updates for instant updates
- Version management
- Rollback capabilities
- Update notifications

### App Store Updates
- Version bumping
- Release notes
- Feature flags
- Gradual rollout

## 📞 Support

For frontend-specific issues:
- Check Expo documentation
- Review React Native guides
- Test on different devices
- Check component documentation

---

**Saranam Frontend** - Your spiritual journey starts here 🙏