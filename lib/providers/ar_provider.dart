import 'package:flutter/material.dart';

// Stub AR Provider - AR functionality temporarily disabled for compatibility
class ARProvider extends ChangeNotifier {
  bool _isARActive = false;
  bool _isARSupported = false; // Set to false since AR is disabled
  bool _isInitialized = false;
  String? _error = 'AR functionality temporarily disabled for compatibility';
  double _companionScale = 1.0;
  Map<String, dynamic> _arSettings = {};

  // Getters
  bool get isARActive => _isARActive;
  bool get isARSupported => _isARSupported;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  double get companionScale => _companionScale;
  Map<String, dynamic> get arSettings => _arSettings;

  // Initialize AR (stub)
  Future<void> initialize() async {
    try {
      _isARSupported = false; // AR disabled
      _isInitialized = true;
      _error = 'AR functionality temporarily disabled for build compatibility';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Start AR session (stub)
  Future<void> startAR() async {
    _error = 'AR functionality is temporarily disabled';
    notifyListeners();
  }

  // Stop AR session (stub)
  Future<void> stopAR() async {
    _isARActive = false;
    _error = null;
    notifyListeners();
  }

  // Update companion scale
  void updateCompanionScale(double scale) {
    _companionScale = scale.clamp(0.1, 3.0);
    notifyListeners();
  }

  // Place companion in AR (stub)
  Future<void> placeCompanion({
    required String modelPath,
    required List<double> position,
    required List<double> rotation,
  }) async {
    _error = 'AR functionality is temporarily disabled';
    notifyListeners();
  }

  // Update AR settings
  void updateARSettings(Map<String, dynamic> settings) {
    _arSettings = {..._arSettings, ...settings};
    notifyListeners();
  }

  // Reset AR
  Future<void> resetAR() async {
    _isARActive = false;
    _companionScale = 1.0;
    _arSettings.clear();
    _error = 'AR functionality is temporarily disabled';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}