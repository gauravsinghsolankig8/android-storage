import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;
  String _currentTheme = 'light';

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;
  String get currentTheme => _currentTheme;

  // Initialize app settings
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentTheme = prefs.getString('currentTheme') ?? 'light';
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing app provider: $e');
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    try {
      _isDarkMode = !_isDarkMode;
      _currentTheme = _isDarkMode ? 'dark' : 'light';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('currentTheme', _currentTheme);
      
      notifyListeners();
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }

  // Set theme
  Future<void> setTheme(String theme) async {
    try {
      _currentTheme = theme;
      _isDarkMode = theme == 'dark';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentTheme', theme);
      await prefs.setBool('isDarkMode', _isDarkMode);
      
      notifyListeners();
    } catch (e) {
      print('Error setting theme: $e');
    }
  }
}