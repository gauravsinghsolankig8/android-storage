import 'package:flutter/material.dart';
import '../services/ar_service.dart';

class ARProvider extends ChangeNotifier {
  final ARService _arService = ARService();
  
  bool _isARActive = false;
  bool _isARSupported = false;
  bool _isInitialized = false;
  String? _error;
  double _companionScale = 1.0;
  Map<String, dynamic> _arSettings = {};

  // Getters
  bool get isARActive => _isARActive;
  bool get isARSupported => _isARSupported;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  double get companionScale => _companionScale;
  Map<String, dynamic> get arSettings => _arSettings;

  // Initialize AR
  Future<void> initialize() async {
    try {
      _isARSupported = await _arService.isARSupported();
      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Start AR session
  Future<void> startAR() async {
    if (!_isARSupported) {
      _error = 'AR is not supported on this device';
      notifyListeners();
      return;
    }

    try {
      await _arService.startARSession();
      _isARActive = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Stop AR session
  Future<void> stopAR() async {
    try {
      await _arService.stopARSession();
      _isARActive = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update companion scale
  void updateCompanionScale(double scale) {
    _companionScale = scale.clamp(0.1, 3.0);
    notifyListeners();
  }

  // Place companion in AR
  Future<void> placeCompanion({
    required String modelPath,
    required List<double> position,
    required List<double> rotation,
  }) async {
    if (!_isARActive) {
      _error = 'AR session is not active';
      notifyListeners();
      return;
    }

    try {
      await _arService.placeModel(
        modelPath: modelPath,
        position: position,
        rotation: rotation,
        scale: _companionScale,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update AR settings
  void updateARSettings(Map<String, dynamic> settings) {
    _arSettings = {..._arSettings, ...settings};
    notifyListeners();
  }

  // Reset AR
  Future<void> resetAR() async {
    try {
      if (_isARActive) {
        await stopAR();
      }
      _companionScale = 1.0;
      _arSettings.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}