import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/ar_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/user_provider.dart';

class ARLobbyScreen extends StatefulWidget {
  const ARLobbyScreen({super.key});

  @override
  State<ARLobbyScreen> createState() => _ARLobbyScreenState();
}

class _ARLobbyScreenState extends State<ARLobbyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize AR provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ARProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Lobby'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Consumer3<ARProvider, MoodProvider, UserProvider>(
        builder: (context, arProvider, moodProvider, userProvider, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F0F23),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Status Header
                  _buildStatusHeader(arProvider),
                  
                  // Main Content
                  Expanded(
                    child: arProvider.isARSupported
                        ? _buildARReadyContent(arProvider, moodProvider, userProvider)
                        : _buildARNotSupportedContent(),
                  ),
                  
                  // Bottom Controls
                  _buildBottomControls(arProvider, moodProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(ARProvider arProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AR Status Indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: arProvider.isARSupported
                          ? [Colors.green, Colors.green.withOpacity(0.3)]
                          : [Colors.red, Colors.red.withOpacity(0.3)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: arProvider.isARSupported
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    arProvider.isARSupported
                        ? Icons.camera_alt
                        : Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            arProvider.isARSupported ? 'AR Ready' : 'AR Not Supported',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            arProvider.isARSupported
                ? 'Your device supports augmented reality'
                : 'This device does not support AR features',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildARReadyContent(
    ARProvider arProvider,
    MoodProvider moodProvider,
    UserProvider userProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Companion Info
          _buildCompanionInfo(moodProvider, userProvider),
          const SizedBox(height: 30),
          
          // AR Controls
          _buildARControls(arProvider),
          const SizedBox(height: 30),
          
          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildARNotSupportedContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phonelink_off,
              color: Colors.white54,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'AR Not Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Augmented Reality features require a newer device with ARCore (Android) or ARKit (iOS) support.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Get.toNamed('/chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'Continue with Chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionInfo(MoodProvider moodProvider, UserProvider userProvider) {
    final currentMood = moodProvider.currentMood;
    final currentOutfit = userProvider.currentUser?.currentOutfit ?? 'default';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Your AR Companion',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Mood
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: currentMood.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMoodIcon(currentMood.name),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentMood.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Mood',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Outfit
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.style,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentOutfit.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Outfit',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildARControls(ARProvider arProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'AR Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Scale Control
          Row(
            children: [
              const Icon(Icons.zoom_in, color: Colors.white70),
              const SizedBox(width: 12),
              const Text(
                'Size',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: arProvider.companionScale,
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    arProvider.updateCompanionScale(value);
                  },
                ),
              ),
              Text(
                '${arProvider.companionScale.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'AR Instructions',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Point your camera at a flat surface\n'
            '2. Move your device slowly to scan the area\n'
            '3. Tap to place your AI companion\n'
            '4. Interact by tapping on your companion',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(ARProvider arProvider, MoodProvider moodProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (arProvider.isARSupported) ...[
            // Start AR Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: arProvider.isARActive ? null : () => _startAR(arProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: arProvider.isARActive
                      ? Colors.grey
                      : moodProvider.currentMood.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  arProvider.isARActive ? 'AR Active' : 'Start AR Experience',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Alternative Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.toNamed('/mood-selector'),
                  child: const Text(
                    'Change Mood',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => Get.toNamed('/chat'),
                  child: const Text(
                    'Chat Instead',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(String moodName) {
    switch (moodName.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied;
      case 'romantic': return Icons.favorite;
      case 'villain': return Icons.whatshot;
      case 'sleepy': return Icons.bedtime;
      case 'joker': return Icons.emoji_emotions;
      default: return Icons.mood;
    }
  }

  void _startAR(ARProvider arProvider) async {
    setState(() {
      _isScanning = true;
    });

    _animationController.repeat();

    try {
      await arProvider.startAR();
      // Here you would typically navigate to the actual AR camera view
      // For now, we'll simulate AR mode
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AR mode activated! (Demo)'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Stop AR',
            textColor: Colors.white,
            onPressed: () => arProvider.stopAR(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AR Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
      _animationController.stop();
    }
  }
}