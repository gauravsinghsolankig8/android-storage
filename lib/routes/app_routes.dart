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

// Admin Panel Screens
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_content_screen.dart';

class AppRoutes {
  // User App Routes
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

  // Admin Panel Routes
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminContent = '/admin/content';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSupport = '/admin/support';
  static const String adminFinance = '/admin/finance';
  static const String adminSettings = '/admin/settings';
  static const String adminReports = '/admin/reports';

  static List<GetPage> routes = [
    // User App Routes
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

    // Admin Panel Routes
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminUsers,
      page: () => const AdminUsersScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminContent,
      page: () => const AdminContentScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminAnalytics,
      page: () => const AdminAnalyticsPlaceholder(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminSupport,
      page: () => const AdminSupportPlaceholder(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminFinance,
      page: () => const AdminFinancePlaceholder(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminSettings,
      page: () => const AdminSettingsPlaceholder(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: adminReports,
      page: () => const AdminReportsPlaceholder(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AdminAuthMiddleware()],
    ),
  ];

  // User App Navigation helpers
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

  // Admin Panel Navigation helpers
  static void toAdminDashboard() => Get.offAllNamed(adminDashboard);
  static void toAdminUsers() => Get.toNamed(adminUsers);
  static void toAdminContent() => Get.toNamed(adminContent);
  static void toAdminAnalytics() => Get.toNamed(adminAnalytics);
  static void toAdminSupport() => Get.toNamed(adminSupport);
  static void toAdminFinance() => Get.toNamed(adminFinance);
  static void toAdminSettings() => Get.toNamed(adminSettings);
  static void toAdminReports() => Get.toNamed(adminReports);

  // Back navigation
  static void back() => Get.back();
  static void backToHome() => Get.offAllNamed(home);
  static void backToAdminDashboard() => Get.offAllNamed(adminDashboard);
}

// Admin Authentication Middleware
class AdminAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // In a real app, check if user is authenticated admin
    // For demo purposes, we'll allow access
    // if (!isAdmin) return const RouteSettings(name: '/login');
    return null;
  }
}

// Placeholder screens for admin sections not yet implemented
class AdminAnalyticsPlaceholder extends StatelessWidget {
  const AdminAnalyticsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Advanced analytics features coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSupportPlaceholder extends StatelessWidget {
  const AdminSupportPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support_agent, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Support Center',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Customer support features coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminFinancePlaceholder extends StatelessWidget {
  const AdminFinancePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Financial Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Financial reporting features coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsPlaceholder extends StatelessWidget {
  const AdminSettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'System Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'System configuration features coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminReportsPlaceholder extends StatelessWidget {
  const AdminReportsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Reports & Insights',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Reporting features coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}