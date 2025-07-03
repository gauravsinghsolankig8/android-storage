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
      _availableMoods = [
        MoodModel(
          id: 'happy',
          name: 'Happy',
          description: 'Your cheerful and energetic companion',
          personality: 'Upbeat, optimistic, and full of joy. Always sees the bright side of things.',
          animationUrl: 'assets/animations/happy.json',
          unlockPrice: 0,
          isUnlocked: true,
        ),
        MoodModel(
          id: 'romantic',
          name: 'Romantic',
          description: 'Your loving and affectionate companion',
          personality: 'Sweet, caring, and romantic. Speaks with warmth and affection.',
          animationUrl: 'assets/animations/romantic.json',
          unlockPrice: 100,
          isUnlocked: false,
        ),
        MoodModel(
          id: 'sleepy',
          name: 'Sleepy',
          description: 'Your drowsy and calm companion',
          personality: 'Relaxed, calm, and slightly tired. Speaks slowly and peacefully.',
          animationUrl: 'assets/animations/sleepy.json',
          unlockPrice: 150,
          isUnlocked: false,
        ),
        MoodModel(
          id: 'villain',
          name: 'Villain',
          description: 'Your mischievous and dramatic companion',
          personality: 'Dramatic, scheming, and playfully evil. Loves theatrics and grand plans.',
          animationUrl: 'assets/animations/villain.json',
          unlockPrice: 200,
          isUnlocked: false,
        ),
        MoodModel(
          id: 'joker',
          name: 'Joker',
          description: 'Your funny and prankster companion',
          personality: 'Humorous, witty, and loves jokes. Always ready with a pun or prank.',
          animationUrl: 'assets/animations/joker.json',
          unlockPrice: 250,
          isUnlocked: false,
        ),
      ];

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
        _error = 'Mood ${mood.name} is not unlocked yet';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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