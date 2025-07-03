import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
import 'providers/ar_provider.dart';

// Routes & Screens
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  Hive.registerAdapter(MoodModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(OutfitModelAdapter());
  Hive.registerAdapter(SecretCommandModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<MoodModel>('moods');
  await Hive.openBox<ConversationModel>('conversations');
  await Hive.openBox<OutfitModel>('outfits');
  
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
          return MaterialApp(
            title: 'EchoBuddy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRoutes.generateRoute,
            home: const SplashScreen(),
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