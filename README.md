# 📱 EchoBuddy - Your Advanced AI Friend with AR

> An immersive Flutter app featuring AI-powered conversations, AR 3D companions, voice interactions, mood-based personalities, and gamified experiences.

## ✨ Features

### 🧍 AR 3D AI Friend
- **Real-time AR buddy** rendered in your space using `ar_flutter_plugin`
- **3D outfit changes** with dynamic GLB model loading
- **Interactive animations** - tap, gesture, and mood-responsive behaviors
- **Voice & text chat** with GPT-4o powered personality
- **Emotional modes**: Happy, Romantic, Villain, Sleepy, Joker

### 🏠 AR Lobby Experience
- **PUBG-style scene** with persistent buddy presence
- **Idle animations**: wave, blink, dance, breathe
- **Floating UI controls** for Chat, Moods, Shop, Inventory, Settings
- **Ambient background audio** for immersion

### 💬 AI Assistant Features
- **GPT-4o integration** with personality-based responses
- **Memory system** - remembers conversations and user preferences
- **Voice input/output** with mood-specific voice styles
- **Assistant capabilities**: Reminders, Notes, Study help, Schedule summaries
- **Smart conversation** with context awareness

### 🎭 Advanced Mood System
- **5 unique personalities** with distinct behaviors:
  - 😊 **Happy**: Cheerful and optimistic
  - ❤️ **Romantic**: Sweet and loving (Pro)
  - 😴 **Sleepy**: Drowsy and peaceful
  - 😈 **Villain**: Mischievous dark side (Pro)
  - 🤡 **Joker**: Funny prankster (Pro)
- **Auto mood detection** from user messages
- **Mood-specific animations** and voice styles

### 👗 Outfit & Customization System
- **3D outfit marketplace** with various categories
- **Rarity system**: Common, Uncommon, Rare, Epic, Legendary
- **Coin & real money** purchasing options
- **Live AR preview** before purchase
- **Outfit categories**: Casual, Formal, Party, Themed, Sleepwear

### 😂 Secret Commands & Easter Eggs
- **"Roast me"** → Funny AI roasts with animations
- **"Clone me"** → Duplicate buddy effect
- **"Biryani Protocol"** → Maximum chaos mode
- **"Dance battle"** → Interactive dance sequences
- **"Magic show"** → AR magic tricks
- **"Tell me a secret"** → Intimate conversations

### 🪙 Gamification & Rewards
- **Coin system** with multiple earning methods:
  - Daily login rewards
  - AI interaction bonuses
  - Quiz completions
  - Long conversation rewards
  - Secret command discoveries
- **Statistics tracking** for engagement
- **Achievement system** (planned)

### 💸 Monetization
- **Monthly Pro subscription** (₹99/mo) with:
  - All moods unlocked
  - Advanced memory features
  - Premium outfits
  - Priority AI responses
- **One-time outfit purchases** (₹29-₹149)
- **"Try Pro for 1 Day"** feature

## 🏗️ Architecture

### 📁 Project Structure
```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── app_config.dart         # Configuration constants
│   └── theme/
│       └── app_theme.dart      # App theming
├── models/                     # Data models
│   ├── user_model.dart         # User data & preferences
│   ├── mood_model.dart         # Personality configurations
│   ├── outfit_model.dart       # 3D outfit definitions
│   ├── conversation_model.dart # Chat & memory models
│   └── secret_command_model.dart # Easter egg commands
├── services/                   # Core services
│   ├── ai_service.dart         # GPT-4o integration
│   ├── voice_service.dart      # Speech-to-text/TTS
│   └── ar_service.dart         # AR 3D rendering
├── providers/                  # State management
├── screens/                    # UI screens
├── widgets/                    # Reusable components
└── routes/
    └── app_routes.dart         # Navigation system
```

### 🔧 Tech Stack
- **Framework**: Flutter 3.0+
- **State Management**: Provider + GetX
- **AR**: ar_flutter_plugin
- **AI**: OpenAI GPT-4o
- **Voice**: speech_to_text + flutter_tts
- **Database**: Supabase + Hive (local storage)
- **Payments**: Razorpay
- **Animations**: Lottie + Rive
- **3D Models**: GLB format

## 🚀 Setup Instructions

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android SDK (API level 21+)
- iOS 11.0+ (for iOS builds)

### 1. Clone & Install
```bash
git clone <your-repo-url>
cd echobuddy
flutter pub get
```

### 2. Configure API Keys
Create a `.env` file or update `lib/core/app_config.dart`:

```dart
// Replace with your actual API keys
static const String openAIApiKey = 'your_openai_api_key';
static const String supabaseUrl = 'your_supabase_url';
static const String supabaseAnonKey = 'your_supabase_anon_key';
static const String razorpayKey = 'your_razorpay_key';
```

### 3. Setup Supabase Database
Run the SQL scripts in `database/` to create tables:
- `users` - User profiles and preferences
- `conversations` - Chat history
- `outfits` - 3D outfit catalog
- `moods` - Personality configurations
- `secret_commands` - Easter egg commands

### 4. Add 3D Assets
Place your GLB models in:
```
assets/
├── 3d_models/
│   ├── default_buddy.glb
│   ├── casual_cool.glb
│   └── ...
├── images/
├── audio/
└── animations/
```

### 5. Generate Hive Adapters
```bash
flutter packages pub run build_runner build
```

### 6. Run the App
```bash
flutter run
```

## 📱 Screens Overview

### Core Screens
- **Splash Screen** - Animated loading with service initialization
- **Onboarding** - Introduction and personality selection
- **AR Lobby** - Main AR experience with 3D buddy
- **Chat Screen** - AI conversations with voice support
- **Shop** - Outfit marketplace with AR preview
- **Inventory** - Owned outfits and customization
- **Settings** - Preferences and account management

### Additional Screens
- **Mood Selector** - Personality switching interface
- **Stats** - User engagement analytics
- **Memory** - Conversation highlights
- **Quiz** - AI-generated learning content
- **Subscription** - Pro upgrade flow

## 🔮 Future Features

### Phase 2 Enhancements
- **Multiplayer AR** - Share buddy with friends
- **Custom 3D models** - User-uploaded avatars
- **AR games** - Interactive mini-games
- **Social features** - Buddy communities
- **Advanced AI** - Emotional intelligence
- **Wearable integration** - Health data sync

### Phase 3 Expansion
- **Web companion** - Cross-platform sync
- **Smart home integration** - IoT device control
- **Educational content** - Structured learning
- **Enterprise features** - Business applications

## 🧑‍💻 Development

### State Management
- **Providers** for reactive state updates
- **GetX** for navigation and dependencies
- **Hive** for local data persistence
- **Supabase** for cloud synchronization

### Performance Optimization
- **Lazy loading** for 3D models
- **Image caching** for outfit thumbnails
- **Background processing** for AI responses
- **Memory management** for AR sessions

### Testing Strategy
- **Unit tests** for business logic
- **Widget tests** for UI components
- **Integration tests** for user flows
- **AR testing** on multiple devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@echobuddy.app or join our Discord community.

---

**Built with ❤️ for the future of digital companionship**
