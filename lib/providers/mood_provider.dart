import 'package:flutter/material.dart';
import '../models/mood_model.dart';

class MoodProvider extends ChangeNotifier {
  List<MoodModel> _availableMoods = [];
  MoodModel? _currentMood;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MoodModel> get availableMoods => _availableMoods;
  MoodModel? get currentMood => _currentMood;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with default moods
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Initialize default moods
      _availableMoods = MoodModel.defaultMoods;

      // Set default mood
      _currentMood = _availableMoods.first;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change current mood
  void changeMood(String moodId) {
    try {
      final mood = _availableMoods.firstWhere(
        (m) => m.id == moodId,
        orElse: () => _availableMoods.first,
      );
      
      if (mood.isUnlocked) {
        _currentMood = mood;
        notifyListeners();
      } else {
        _error = 'Mood ${mood.displayName} is not unlocked yet';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Set current mood (alias for changeMood)
  void setCurrentMood(MoodModel mood) {
    changeMood(mood.id);
  }

  // Unlock mood
  bool unlockMood(String moodId, int availableCoins) {
    try {
      final moodIndex = _availableMoods.indexWhere((m) => m.id == moodId);
      if (moodIndex == -1) return false;

      final mood = _availableMoods[moodIndex];
      if (mood.isUnlocked) return true;

      if (availableCoins >= mood.unlockPrice) {
        _availableMoods[moodIndex] = mood.copyWith(isUnlocked: true);
        notifyListeners();
        return true;
      } else {
        _error = 'Not enough coins to unlock ${mood.name}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get mood by ID
  MoodModel? getMoodById(String moodId) {
    try {
      return _availableMoods.firstWhere(
        (mood) => mood.id == moodId,
        orElse: () => _availableMoods.first,
      );
    } catch (e) {
      return null;
    }
  }

  // Get unlocked moods
  List<MoodModel> get unlockedMoods {
    return _availableMoods.where((mood) => mood.isUnlocked).toList();
  }

  // Get locked moods
  List<MoodModel> get lockedMoods {
    return _availableMoods.where((mood) => !mood.isUnlocked).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}