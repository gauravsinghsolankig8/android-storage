class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // OpenAI Configuration
  static const String openAIApiKey = 'YOUR_OPENAI_API_KEY';
  static const String openAIModel = 'gpt-4o';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'echobuddy-app';
  
  // Razorpay Configuration
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY';
  
  // App Configuration
  static const String appName = 'EchoBuddy';
  static const String appVersion = '1.0.0';
  
  // Subscription Configuration
  static const double monthlySubscriptionPrice = 99.0;
  static const String currency = 'INR';
  
  // Coin Configuration
  static const int dailyLoginCoins = 10;
  static const int prankCoins = 5;
  static const int aiInteractionCoins = 2;
  static const int quizCompleteCoins = 15;
  static const int longInteractionCoins = 20;
  static const int longInteractionMinutes = 20;
  
  // AI Configuration
  static const double aiTemperature = 0.8;
  static const int maxTokens = 500;
  static const int conversationMemoryLimit = 50;
  
  // AR Configuration
  static const String defaultBuddyModel = 'default_buddy.glb';
  static const double arScale = 1.0;
  
  // Animation Configuration
  static const int animationDuration = 300;
  static const int idleAnimationInterval = 30; // seconds
  
  // Audio Configuration
  static const double defaultVolume = 0.7;
  static const String voiceLanguage = 'en-US';
  
  // Debug Configuration
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  
  // Features Configuration
  static const bool enableVoice = true;
  static const bool enableAR = true;
  static const bool enablePayments = true;
  static const bool enablePushNotifications = true;
}