import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/mood_provider.dart';
import '../providers/user_provider.dart';
import '../models/mood_model.dart';

class MoodSelectorScreen extends StatefulWidget {
  const MoodSelectorScreen({super.key});

  @override
  State<MoodSelectorScreen> createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Mood'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shop),
            onPressed: () => Get.toNamed('/shop'),
          ),
        ],
      ),
      body: Consumer2<MoodProvider, UserProvider>(
        builder: (context, moodProvider, userProvider, child) {
          final allMoods = MoodModel.defaultMoods;
          final unlockedMoods = userProvider.currentUser?.unlockedMoods ?? [];
          final currentMoodId = moodProvider.currentMood.id;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Current Mood Display
                  _buildCurrentMoodCard(moodProvider.currentMood),
                  const SizedBox(height: 24),
                  
                  // Available Moods Header
                  Row(
                    children: [
                      Icon(
                        Icons.mood,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Moods',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Moods Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: allMoods.length,
                      itemBuilder: (context, index) {
                        final mood = allMoods[index];
                        final isUnlocked = unlockedMoods.contains(mood.id) || !mood.isPro;
                        final isSelected = mood.id == currentMoodId;
                        
                        return _buildMoodCard(
                          mood,
                          isUnlocked,
                          isSelected,
                          moodProvider,
                          userProvider,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentMoodCard(MoodModel currentMood) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentMood.color.withOpacity(0.8),
            currentMood.color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: currentMood.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Mood',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            _getMoodIcon(currentMood.name),
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            currentMood.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentMood.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(
    MoodModel mood,
    bool isUnlocked,
    bool isSelected,
    MoodProvider moodProvider,
    UserProvider userProvider,
  ) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          _selectMood(mood, moodProvider);
        } else {
          _showPurchaseDialog(mood, userProvider);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    mood.color.withOpacity(0.8),
                    mood.color.withOpacity(0.6),
                  ]
                : [
                    Colors.grey.withOpacity(0.4),
                    Colors.grey.withOpacity(0.2),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? mood.color.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getMoodIcon(mood.name),
                    size: 40,
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mood.displayName,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white70 : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Lock Icon
            if (!isUnlocked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            
            // Selected Indicator
            if (isSelected)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            
            // Pro Badge
            if (mood.isPro)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
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

  void _selectMood(MoodModel mood, MoodProvider moodProvider) {
    moodProvider.setCurrentMood(mood);
    
    // Show confirmation with haptic feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${mood.displayName} mood!'),
        backgroundColor: mood.color,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Chat Now',
          textColor: Colors.white,
          onPressed: () => Get.toNamed('/chat'),
        ),
      ),
    );

    // Animate the selection
    _animationController.reset();
    _animationController.forward();
  }

  void _showPurchaseDialog(MoodModel mood, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getMoodIcon(mood.name),
              color: mood.color,
            ),
            const SizedBox(width: 8),
            Text('Unlock ${mood.displayName}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mood.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: mood.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${mood.unlockCost} coins',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${userProvider.currentUser?.coins ?? 0} coins',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/shop');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mood.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Shop'),
          ),
        ],
      ),
    );
  }
}