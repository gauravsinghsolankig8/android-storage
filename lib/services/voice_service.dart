import 'dart:async';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/app_config.dart';
import '../models/mood_model.dart';
import '../models/user_model.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // Speech to Text
  final SpeechToText _speechToText = SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  // Text to Speech
  final FlutterTts _flutterTts = FlutterTts();
  bool _ttsInitialized = false;
  bool _isSpeaking = false;

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stream controllers
  final StreamController<String> _speechController = StreamController<String>.broadcast();
  final StreamController<bool> _listeningController = StreamController<bool>.broadcast();
  final StreamController<bool> _speakingController = StreamController<bool>.broadcast();

  // Getters
  Stream<String> get speechStream => _speechController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<bool> get speakingStream => _speakingController.stream;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;

  // Initialize voice services
  Future<bool> initialize() async {
    try {
      await _initializeSpeechToText();
      await _initializeTextToSpeech();
      return true;
    } catch (e) {
      print('Voice service initialization failed: $e');
      return false;
    }
  }

  // Initialize Speech to Text
  Future<void> _initializeSpeechToText() async {
    try {
      _speechInitialized = await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          _listeningController.add(_isListening);
        },
        onError: (error) {
          print('Speech recognition error: $error');
          _isListening = false;
          _listeningController.add(false);
        },
      );
    } catch (e) {
      print('Speech to text initialization failed: $e');
      _speechInitialized = false;
    }
  }

  // Initialize Text to Speech
  Future<void> _initializeTextToSpeech() async {
    try {
      await _flutterTts.setLanguage(AppConfig.voiceLanguage);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(AppConfig.defaultVolume);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _speakingController.add(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _speakingController.add(false);
      });

      _flutterTts.setErrorHandler((message) {
        print('TTS Error: $message');
        _isSpeaking = false;
        _speakingController.add(false);
      });

      _ttsInitialized = true;
    } catch (e) {
      print('Text to speech initialization failed: $e');
      _ttsInitialized = false;
    }
  }

  // Start listening for speech
  Future<void> startListening({
    Duration? timeout,
    String? localeId,
  }) async {
    if (!_speechInitialized || _isListening) return;

    try {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _speechController.add(_lastWords);
        },
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: localeId ?? AppConfig.voiceLanguage,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_speechInitialized || !_isListening) return;

    try {
      await _speechToText.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  // Speak text with mood-based voice
  Future<void> speak({
    required String text,
    MoodModel? mood,
    UserModel? user,
    double? volume,
    double? rate,
    double? pitch,
  }) async {
    if (!_ttsInitialized || text.isEmpty) return;

    try {
      // Stop current speech if speaking
      if (_isSpeaking) {
        await stop();
      }

      // Apply mood-specific voice settings
      await _applyMoodVoiceSettings(mood);

      // Apply user preferences
      if (user?.preferences != null) {
        await _flutterTts.setVolume(volume ?? user!.preferences.voiceVolume);
      }

      // Set custom parameters
      if (rate != null) await _flutterTts.setSpeechRate(rate);
      if (pitch != null) await _flutterTts.setPitch(pitch);

      // Clean text for better speech
      final cleanText = _cleanTextForSpeech(text);
      
      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('Error speaking text: $e');
      _isSpeaking = false;
      _speakingController.add(false);
    }
  }

  // Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _speakingController.add(false);
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  // Play sound effect
  Future<void> playSoundEffect(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('Error playing sound effect: $e');
    }
  }

  // Play background audio
  Future<void> playBackgroundAudio({
    required String audioPath,
    bool loop = true,
    double volume = 0.3,
  }) async {
    try {
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      print('Error playing background audio: $e');
    }
  }

  // Stop background audio
  Future<void> stopBackgroundAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping background audio: $e');
    }
  }

  // Record audio message
  Future<String?> recordAudioMessage({
    required Duration maxDuration,
    String? outputPath,
  }) async {
    try {
      // Implementation would use audio recording plugin
      // For now, return a placeholder path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = outputPath ?? '${directory.path}/voice_message_$timestamp.wav';
      
      // TODO: Implement actual audio recording
      // This would integrate with a recording plugin like record or audio_waveforms
      
      return filePath;
    } catch (e) {
      print('Error recording audio: $e');
      return null;
    }
  }

  // Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      if (!_ttsInitialized) return [];
      
      final voices = await _flutterTts.getVoices;
      return List<Map<String, String>>.from(voices ?? []);
    } catch (e) {
      print('Error getting available voices: $e');
      return [];
    }
  }

  // Set voice by name
  Future<void> setVoice(String voiceName) async {
    try {
      if (!_ttsInitialized) return;
      await _flutterTts.setVoice({
        'name': voiceName,
        'locale': AppConfig.voiceLanguage,
      });
    } catch (e) {
      print('Error setting voice: $e');
    }
  }

  // Check if speech recognition is available
  Future<bool> isSpeechRecognitionAvailable() async {
    try {
      return await _speechToText.hasPermission;
    } catch (e) {
      print('Error checking speech recognition availability: $e');
      return false;
    }
  }

  // Get supported locales for speech recognition
  Future<List<LocaleName>> getSupportedLocales() async {
    try {
      if (!_speechInitialized) return [];
      return await _speechToText.locales();
    } catch (e) {
      print('Error getting supported locales: $e');
      return [];
    }
  }

  // Apply mood-specific voice settings
  Future<void> _applyMoodVoiceSettings(MoodModel? mood) async {
    if (mood == null) return;

    try {
      switch (mood.name.toLowerCase()) {
        case 'happy':
          await _flutterTts.setSpeechRate(0.6);
          await _flutterTts.setPitch(1.2);
          break;
        case 'romantic':
          await _flutterTts.setSpeechRate(0.4);
          await _flutterTts.setPitch(0.9);
          break;
        case 'sleepy':
          await _flutterTts.setSpeechRate(0.3);
          await _flutterTts.setPitch(0.8);
          break;
        case 'villain':
          await _flutterTts.setSpeechRate(0.5);
          await _flutterTts.setPitch(0.7);
          break;
        case 'joker':
          await _flutterTts.setSpeechRate(0.7);
          await _flutterTts.setPitch(1.3);
          break;
        default:
          await _flutterTts.setSpeechRate(0.5);
          await _flutterTts.setPitch(1.0);
      }
    } catch (e) {
      print('Error applying mood voice settings: $e');
    }
  }

  // Clean text for better speech synthesis
  String _cleanTextForSpeech(String text) {
    // Remove excessive emojis and special characters
    String cleaned = text.replaceAll(RegExp(r'[😀-🿿]'), '');
    
    // Replace common symbols with words
    cleaned = cleaned.replaceAll('&', 'and');
    cleaned = cleaned.replaceAll('@', 'at');
    cleaned = cleaned.replaceAll('#', 'hashtag');
    cleaned = cleaned.replaceAll('%', 'percent');
    
    // Replace asterisk actions with pauses
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), '. $1. ');
    
    // Clean up multiple spaces and punctuation
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\.{2,}'), '.');
    cleaned = cleaned.replaceAll(RegExp(r'!{2,}'), '!');
    cleaned = cleaned.replaceAll(RegExp(r'\?{2,}'), '?');
    
    return cleaned.trim();
  }

  // Update voice settings from user preferences
  Future<void> updateVoiceSettings(UserPreferences preferences) async {
    try {
      if (!_ttsInitialized) return;
      
      await _flutterTts.setVolume(preferences.voiceVolume);
      await _flutterTts.setLanguage(preferences.voiceLanguage);
    } catch (e) {
      print('Error updating voice settings: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _speechController.close();
    _listeningController.close();
    _speakingController.close();
    _audioPlayer.dispose();
  }
}