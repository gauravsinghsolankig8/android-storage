import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/user_provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_model.dart';
import '../models/outfit_model.dart';
import '../models/user_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.mood), text: 'Moods'),
            Tab(icon: Icon(Icons.style), text: 'Outfits'),
          ],
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final coins = userProvider.currentUser?.coins ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodsTab(),
          _buildOutfitsTab(),
        ],
      ),
    );
  }

  Widget _buildMoodsTab() {
    return Consumer2<MoodProvider, UserProvider>(
      builder: (context, moodProvider, userProvider, child) {
        final allMoods = MoodModel.defaultMoods;
        final unlockedMoods = userProvider.currentUser?.unlockedMoods ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: allMoods.length,
          itemBuilder: (context, index) {
            final mood = allMoods[index];
            final isUnlocked = unlockedMoods.contains(mood.id) || !mood.isPro;
            return _buildMoodCard(mood, isUnlocked, userProvider);
          },
        );
      },
    );
  }

  Widget _buildOutfitsTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final allOutfits = OutfitModel.defaultOutfits;
        final unlockedOutfits = userProvider.currentUser?.unlockedOutfits ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: allOutfits.length,
          itemBuilder: (context, index) {
            final outfit = allOutfits[index];
            final isUnlocked = unlockedOutfits.contains(outfit.id) || !outfit.isPro;
            return _buildOutfitCard(outfit, isUnlocked, userProvider);
          },
        );
      },
    );
  }

  Widget _buildMoodCard(MoodModel mood, bool isUnlocked, UserProvider userProvider) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mood Header
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mood.color.withOpacity(0.8),
                  mood.color.withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMoodIcon(mood.name),
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          
          // Mood Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mood.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Purchase/Unlock Button
                  if (isUnlocked)
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<MoodProvider>(context, listen: false)
                            .setCurrentMood(mood);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${mood.displayName} mood!'),
                            backgroundColor: mood.color,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mood.color,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Use'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _purchaseMood(mood, userProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, size: 16),
                          const SizedBox(width: 4),
                          Text('${mood.unlockCost}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(OutfitModel outfit, bool isUnlocked, UserProvider userProvider) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Outfit Preview
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  outfit.color.withOpacity(0.8),
                  outfit.color.withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getOutfitIcon(outfit.category),
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        outfit.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          
          // Outfit Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Purchase/Preview Button
                  if (isUnlocked)
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/outfit-preview', arguments: {'outfitId': outfit.id});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: outfit.color,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Preview'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _purchaseOutfit(outfit, userProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, size: 16),
                          const SizedBox(width: 4),
                          Text('${outfit.unlockCost}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
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

  IconData _getOutfitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'casual': return Icons.checkroom;
      case 'formal': return Icons.business_center;
      case 'fantasy': return Icons.auto_awesome;
      case 'seasonal': return Icons.ac_unit;
      default: return Icons.style;
    }
  }

  void _purchaseMood(MoodModel mood, UserProvider userProvider) {
    final currentCoins = userProvider.currentUser?.coins ?? 0;
    
    if (currentCoins < mood.unlockCost) {
      _showInsufficientCoinsDialog(mood.unlockCost, currentCoins);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${mood.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: mood.color,
              radius: 30,
              child: Icon(
                _getMoodIcon(mood.name),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(mood.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${mood.unlockCost} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
              userProvider.purchaseMood(mood.id, mood.unlockCost);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${mood.displayName} mood unlocked!'),
                  backgroundColor: mood.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mood.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _purchaseOutfit(OutfitModel outfit, UserProvider userProvider) {
    final currentCoins = userProvider.currentUser?.coins ?? 0;
    
    if (currentCoins < outfit.unlockCost) {
      _showInsufficientCoinsDialog(outfit.unlockCost, currentCoins);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${outfit.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: outfit.color,
              radius: 30,
              child: Icon(
                _getOutfitIcon(outfit.category),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(outfit.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${outfit.unlockCost} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
              userProvider.purchaseOutfit(outfit.id, outfit.unlockCost);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${outfit.displayName} outfit unlocked!'),
                  backgroundColor: outfit.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: outfit.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCoinsDialog(int required, int current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'You need $required coins but only have $current coins.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Earn more coins by chatting with your AI companion!',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/chat');
            },
            child: const Text('Start Chatting'),
          ),
        ],
      ),
    );
  }
}