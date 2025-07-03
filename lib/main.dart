import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/app_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/ar_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/user_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/mood_provider.dart';
import 'services/supabase_service.dart';
import 'services/ai_service.dart';
import 'services/voice_service.dart';
import 'services/ar_service.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  // Request permissions
  await _requestPermissions();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(EchoBuddyApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.notification,
  ].request();
}

class EchoBuddyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ARProvider()),
            ChangeNotifierProvider(create: (_) => AudioProvider()),
            ChangeNotifierProvider(create: (_) => ShopProvider()),
            ChangeNotifierProvider(create: (_) => MoodProvider()),
          ],
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return GetMaterialApp(
                title: 'EchoBuddy',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                initialRoute: AppRoutes.splash,
                getPages: AppRoutes.routes,
                home: SplashScreen(),
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}