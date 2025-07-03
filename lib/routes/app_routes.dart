import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/ar_lobby_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/mood_selector_screen.dart';
import '../screens/outfit_preview_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/memory_screen.dart';
import '../screens/quiz_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String arLobby = '/ar-lobby';
  static const String chat = '/chat';
  static const String shop = '/shop';
  static const String inventory = '/inventory';
  static const String settings = '/settings';
  static const String moodSelector = '/mood-selector';
  static const String outfitPreview = '/outfit-preview';
  static const String subscription = '/subscription';
  static const String stats = '/stats';
  static const String memory = '/memory';
  static const String quiz = '/quiz';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: onboarding,
      page: () => OnboardingScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: arLobby,
      page: () => ARLobbyScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: chat,
      page: () => ChatScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: shop,
      page: () => ShopScreen(),
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: inventory,
      page: () => InventoryScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: settings,
      page: () => SettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: moodSelector,
      page: () => MoodSelectorScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: outfitPreview,
      page: () => OutfitPreviewScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: subscription,
      page: () => SubscriptionScreen(),
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: stats,
      page: () => StatsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: memory,
      page: () => MemoryScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: quiz,
      page: () => QuizScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  // Navigation helpers
  static void toSplash() => Get.offAllNamed(splash);
  static void toOnboarding() => Get.offAllNamed(onboarding);
  static void toHome() => Get.offAllNamed(home);
  static void toARLobby() => Get.toNamed(arLobby);
  static void toChat() => Get.toNamed(chat);
  static void toShop() => Get.toNamed(shop);
  static void toInventory() => Get.toNamed(inventory);
  static void toSettings() => Get.toNamed(settings);
  static void toMoodSelector() => Get.toNamed(moodSelector);
  static void toOutfitPreview({String? outfitId}) => Get.toNamed(
    outfitPreview,
    arguments: {'outfitId': outfitId},
  );
  static void toSubscription() => Get.toNamed(subscription);
  static void toStats() => Get.toNamed(stats);
  static void toMemory() => Get.toNamed(memory);
  static void toQuiz({String? quizType}) => Get.toNamed(
    quiz,
    arguments: {'quizType': quizType},
  );

  // Back navigation
  static void back() => Get.back();
  static void backToHome() => Get.offAllNamed(home);
}