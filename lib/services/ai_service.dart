import 'dart:async';
import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import '../models/mood_model.dart';
import '../models/conversation_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  OpenAI? _openAI;
  bool _isInitialized = false;

  // Initialize the AI service
  Future<bool> initialize({String? apiKey}) async {
    try {
      // For development, use a placeholder
      // In production, you'd get this from environment or secure storage
      final key = apiKey ?? 'your-openai-api-key-here';
      
      _openAI = OpenAI.instance.build(
        token: key,
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 30),
          connectTimeout: const Duration(seconds: 30),
        ),
      );
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize AI service: $e');
      return false;
    }
  }

  // Generate response based on mood and conversation history
  Future<String> generateResponse({
    required String message,
    required MoodModel mood,
    List<MessageModel>? conversationHistory,
  }) async {
    if (!_isInitialized) {
      // Return fallback responses if not initialized
      return _getFallbackResponse(message, mood);
    }

    try {
      // Build conversation context
      final messages = <Messages>[];
      
      // System message with mood personality
      messages.add(Messages(
        role: Role.system,
        content: _buildSystemPrompt(mood),
      ));

      // Add conversation history (last 10 messages for context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 10 
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;
          
        for (final msg in recentHistory) {
          messages.add(Messages(
            role: msg.isFromUser ? Role.user : Role.assistant,
            content: msg.content,
          ));
        }
      }

      // Add current message
      messages.add(Messages(
        role: Role.user,
        content: message,
      ));

      // Generate response
      final request = ChatCompleteText(
        messages: messages,
        maxToken: 150,
        model: GptTurbo0301ChatModel(),
        temperature: 0.8,
      );

      final response = await _openAI!.onChatCompletion(request: request);
      
      if (response?.choices.isNotEmpty == true) {
        return response!.choices.first.message?.content?.trim() ?? 
               _getFallbackResponse(message, mood);
      }
      
      return _getFallbackResponse(message, mood);
    } catch (e) {
      print('Error generating AI response: $e');
      return _getFallbackResponse(message, mood);
    }
  }

  // Build system prompt based on mood
  String _buildSystemPrompt(MoodModel mood) {
    return '''
You are EchoBuddy, a virtual companion with the "${mood.name}" personality.

Personality: ${mood.personality}

Instructions:
- Respond in character as a ${mood.name.toLowerCase()} companion
- Keep responses conversational and engaging
- Use emojis occasionally but don't overdo it
- Be helpful and supportive
- Maintain the mood's characteristic tone and style
- Keep responses under 100 words
- Be friendly and relatable
''';
  }

  // Fallback responses when AI is not available
  String _getFallbackResponse(String message, MoodModel mood) {
    final responses = _getFallbackResponsesByMood(mood);
    final randomIndex = DateTime.now().millisecond % responses.length;
    return responses[randomIndex];
  }

  // Get mood-specific fallback responses
  List<String> _getFallbackResponsesByMood(MoodModel mood) {
    switch (mood.name.toLowerCase()) {
      case 'happy':
        return [
          "That's so exciting! 😊 Tell me more!",
          "I love your enthusiasm! 🌟",
          "You always brighten my day! ✨",
          "That sounds wonderful! 😄",
          "I'm so happy to chat with you! 💫",
        ];
      case 'romantic':
        return [
          "You have such a beautiful way with words... 💕",
          "That makes my heart flutter... 🌹",
          "You're absolutely lovely, darling... 💖",
          "How romantic of you to share that... 🥰",
          "You make everything feel like poetry... 💝",
        ];
      case 'sleepy':
        return [
          "Mmm... that sounds nice... �",
          "I'm listening... just a bit drowsy... �",
          "That's... interesting... *yawn* 🥱",
          "Tell me more... softly... 😌",
          "I could listen to you all night... 🌙",
        ];
      case 'villain':
        return [
          "Excellent... I have plans for this information... 😈",
          "Muahahaha! How deliciously wicked! 🦹‍♀️",
          "You've given me a wonderfully evil idea... 👿",
          "Perfect... everything is going according to plan... 🔥",
          "You would make an excellent minion... 😏",
        ];
      case 'joker':
        return [
          "Haha! That reminds me of a joke... 😂",
          "You're funnier than you think! 🤣",
          "Why did the chicken cross the road? To get away from my jokes! 😄",
          "That's hilarious! Got any more? 😆",
          "You know what? You're pretty cool! 🎭",
        ];
      default:
        return [
          "That's interesting! Tell me more.",
          "I'd love to hear your thoughts on that.",
          "Thanks for sharing that with me!",
          "How do you feel about that?",
          "I'm here and listening!",
        ];
    }
  }

  // Check if AI service is available
  bool get isAvailable => _isInitialized && _openAI != null;

  // Dispose resources
  void dispose() {
    _openAI = null;
    _isInitialized = false;
  }
}