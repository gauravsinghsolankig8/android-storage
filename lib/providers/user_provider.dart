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
        preferences: UserPreferences(),
        stats: UserStats(),
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

  // Logout
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}