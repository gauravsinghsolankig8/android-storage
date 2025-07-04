import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

// Core & Config
import 'core/theme/app_theme.dart';
import 'core/app_config.dart';

// Models (Hive)
import 'models/user_model.dart';
import 'models/mood_model.dart';
import 'models/conversation_model.dart';
import 'models/outfit_model.dart';
import 'models/secret_command_model.dart';

// Providers
import 'providers/app_provider.dart';
import 'providers/user_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/ar_provider.dart'; // Stub AR provider

// Routes & Screens
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters - User Models
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  
  // Register Hive Adapters - Mood Models
  Hive.registerAdapter(MoodModelAdapter());
  Hive.registerAdapter(MoodBehaviorAdapter());
  
  // Register Hive Adapters - Conversation Models
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(MessageMetadataAdapter());
  Hive.registerAdapter(ConversationContextAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(MessageSenderAdapter());
  
  // Register Hive Adapters - Outfit Models
  Hive.registerAdapter(OutfitModelAdapter());
  Hive.registerAdapter(OutfitAssetsAdapter());
  
  // Register Hive Adapters - Secret Command Models
  Hive.registerAdapter(SecretCommandModelAdapter());
  Hive.registerAdapter(CommandEffectAdapter());
  Hive.registerAdapter(CommandTypeAdapter());
  Hive.registerAdapter(EffectTypeAdapter());
  
  // Open Hive boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<MoodModel>('moods');
  await Hive.openBox<ConversationModel>('conversations');
  await Hive.openBox<OutfitModel>('outfits');
  await Hive.openBox('settings');
  
  runApp(const EchoBuddyApp());
}

class EchoBuddyApp extends StatelessWidget {
  const EchoBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ARProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return GetMaterialApp(
            title: 'EchoBuddy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            getPages: AppRoutes.routes,
            initialRoute: AppRoutes.splash,
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              final scaleFactor = AppConfig.textScaleFactor;
              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: TextScaler.linear(scaleFactor),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}