import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../core/app_config.dart';
import '../routes/app_routes.dart';
import '../services/voice_service.dart';
import '../services/ai_service.dart';
import '../services/ar_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _servicesInitialized = false;
  String _loadingText = 'Waking up your buddy...';
  double _loadingProgress = 0.0;

  final List<String> _loadingMessages = [
    'Waking up your buddy...',
    'Loading emotions...',
    'Preparing voice systems...',
    'Initializing AR magic...',
    'Connecting to AI brain...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _slideController.forward();
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Initialize services one by one with progress updates
      await _initializeWithProgress();
      
      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Navigate to next screen
      _navigateToNextScreen();
    } catch (e) {
      print('Initialization error: $e');
      // Still navigate even if some services fail
      _navigateToNextScreen();
    }
  }

  Future<void> _initializeWithProgress() async {
    // Initialize Voice Service
    _updateLoadingState(0, _loadingMessages[0]);
    await Future.delayed(const Duration(milliseconds: 800));
    
    final voiceInitialized = await VoiceService().initialize();
    _updateLoadingState(0.2, _loadingMessages[1]);
    await Future.delayed(const Duration(milliseconds: 600));

    // Initialize AI Service (mock initialization)
    _updateLoadingState(0.4, _loadingMessages[2]);
    await Future.delayed(const Duration(milliseconds: 700));

    // Initialize AR Service (mock initialization)
    _updateLoadingState(0.6, _loadingMessages[3]);
    await Future.delayed(const Duration(milliseconds: 800));

    // Final preparations
    _updateLoadingState(0.8, _loadingMessages[4]);
    await Future.delayed(const Duration(milliseconds: 600));

    _updateLoadingState(1.0, _loadingMessages[5]);
    await Future.delayed(const Duration(milliseconds: 500));

    _servicesInitialized = true;
  }

  void _updateLoadingState(double progress, String message) {
    if (mounted) {
      setState(() {
        _loadingProgress = progress;
        _loadingText = message;
      });
    }
  }

  void _navigateToNextScreen() {
    // Check if user has completed onboarding
    // For now, always go to onboarding
    AppRoutes.toOnboarding();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacer
              SizedBox(height: 100.h),
              
              // Logo and mascot area
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo/mascot
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: 200.w,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.9),
                                          AppTheme.primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.android,
                                        size: 80.sp,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // App name with animated text
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                AppConfig.appName,
                                style: AppTheme.headingLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48.sp,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Your AI Friend Evolved',
                                    textStyle: AppTheme.bodyLarge.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18.sp,
                                      letterSpacing: 1.2,
                                    ),
                                    speed: const Duration(milliseconds: 100),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loading section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading animation
                    SizedBox(
                      width: 60.w,
                      height: 60.h,
                      child: CircularProgressIndicator(
                        value: _loadingProgress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Loading text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingText,
                        key: ValueKey(_loadingText),
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Progress percentage
                    Text(
                      '${(_loadingProgress * 100).toInt()}%',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom section
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Column(
                  children: [
                    // Version info
                    Text(
                      'Version ${AppConfig.appVersion}',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Company/developer info
                    Text(
                      'Made with ❤️ for digital friendships',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}