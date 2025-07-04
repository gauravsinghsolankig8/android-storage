import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/ai_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isPro => _currentUser?.isProActive ?? false;

  // Initialize with default user for testing
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create default user for development
      _currentUser = UserModel(
        id: 'dev_user_001',
        name: 'Test User',
        email: 'test@example.com',
        preferences: UserPreferences(),
        stats: UserStats(),
        coins: 100, // Start with some coins for testing
        unlockedMoods: ['happy'], // Start with basic mood unlocked
        unlockedOutfits: ['default'], // Start with default outfit
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // Add coins
  void addCoins(int amount) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins + amount,
        stats: _currentUser!.stats.copyWith(
          totalCoinsEarned: _currentUser!.stats.totalCoinsEarned + amount,
        ),
      );
      updateUser(updatedUser);
    }
  }

  // Spend coins
  bool spendCoins(int amount) {
    if (_currentUser != null && _currentUser!.coins >= amount) {
      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins - amount,
        stats: _currentUser!.stats.copyWith(
          totalCoinsSpent: _currentUser!.stats.totalCoinsSpent + amount,
        ),
      );
      updateUser(updatedUser);
      return true;
    }
    return false;
  }

  // Purchase mood
  void purchaseMood(String moodId, int cost) {
    if (_currentUser != null && _currentUser!.coins >= cost) {
      final unlockedMoods = List<String>.from(_currentUser!.unlockedMoods);
      if (!unlockedMoods.contains(moodId)) {
        unlockedMoods.add(moodId);
        final updatedUser = _currentUser!.copyWith(
          coins: _currentUser!.coins - cost,
          unlockedMoods: unlockedMoods,
          stats: _currentUser!.stats.copyWith(
            totalCoinsSpent: _currentUser!.stats.totalCoinsSpent + cost,
          ),
        );
        updateUser(updatedUser);
      }
    }
  }

  // Purchase outfit
  void purchaseOutfit(String outfitId, int cost) {
    if (_currentUser != null && _currentUser!.coins >= cost) {
      final unlockedOutfits = List<String>.from(_currentUser!.unlockedOutfits);
      if (!unlockedOutfits.contains(outfitId)) {
        unlockedOutfits.add(outfitId);
        final updatedUser = _currentUser!.copyWith(
          coins: _currentUser!.coins - cost,
          unlockedOutfits: unlockedOutfits,
          stats: _currentUser!.stats.copyWith(
            totalCoinsSpent: _currentUser!.stats.totalCoinsSpent + cost,
          ),
        );
        updateUser(updatedUser);
      }
    }
  }

  // Change mood
  void changeMood(String moodName) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(currentMood: moodName);
      updateUser(updatedUser);
    }
  }

  // Change outfit
  void changeOutfit(String outfitName) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(currentOutfit: outfitName);
      updateUser(updatedUser);
    }
  }

  // Update preferences
  void updatePreferences(UserPreferences preferences) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(preferences: preferences);
      updateUser(updatedUser);
    }
  }

  // Voice settings updates
  void updateVoiceVolume(double volume) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        voiceVolume: volume,
      );
      updatePreferences(updatedPreferences);
    }
  }

  void updateVoiceLanguage(String language) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        voiceLanguage: language,
      );
      updatePreferences(updatedPreferences);
    }
  }

  void updateAutoPlayVoice(bool enabled) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        autoPlayVoice: enabled,
      );
      updatePreferences(updatedPreferences);
    }
  }

  void updateVoiceInput(bool enabled) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        voiceInputEnabled: enabled,
      );
      updatePreferences(updatedPreferences);
    }
  }

  // General preference updates
  void updateNotifications(bool enabled) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        notificationsEnabled: enabled,
      );
      updatePreferences(updatedPreferences);
    }
  }

  void updateHaptics(bool enabled) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        hapticsEnabled: enabled,
      );
      updatePreferences(updatedPreferences);
    }
  }

  void updateAnalytics(bool enabled) {
    if (_currentUser != null) {
      final updatedPreferences = _currentUser!.preferences.copyWith(
        analyticsEnabled: enabled,
      );
      updatePreferences(updatedPreferences);
    }
  }

  // Increment chat count and award coins
  void incrementChatCount() {
    if (_currentUser != null) {
      final newChatCount = _currentUser!.stats.totalChats + 1;
      final coinsToAdd = 5; // Award 5 coins per chat
      
      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins + coinsToAdd,
        stats: _currentUser!.stats.copyWith(
          totalChats: newChatCount,
          totalCoinsEarned: _currentUser!.stats.totalCoinsEarned + coinsToAdd,
        ),
      );
      updateUser(updatedUser);
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}