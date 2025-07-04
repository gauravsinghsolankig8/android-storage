import 'dart:async';
import 'dart:math';
import '../models/mood_model.dart';
import '../models/conversation_model.dart';
import '../core/app_config.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _useOpenAI = false;
  final Random _random = Random();

  // Initialize the AI service
  Future<bool> initialize({String? apiKey}) async {
    try {
      // Check if we have a valid OpenAI API key
      final key = apiKey ?? AppConfig.openAIApiKey;
      
      if (key != 'YOUR_OPENAI_API_KEY' && key.isNotEmpty && key.startsWith('sk-')) {
        // Only enable OpenAI if we have a valid key
        _useOpenAI = true;
        print('AI Service: OpenAI integration enabled');
      } else {
        // Use offline mode with intelligent fallbacks
        _useOpenAI = false;
        print('AI Service: Running in offline mode with intelligent responses');
      }
      
      return true;
    } catch (e) {
      print('AI Service: Falling back to offline mode - $e');
      _useOpenAI = false;
      return true; // Always return true as we can work offline
    }
  }

  // Generate response based on mood and conversation history
  Future<String> generateResponse({
    required String message,
    required MoodModel mood,
    List<MessageModel>? conversationHistory,
  }) async {
    try {
      if (_useOpenAI) {
        // TODO: Implement OpenAI integration when API key is available
        return await _generateOpenAIResponse(message, mood, conversationHistory);
      } else {
        // Use intelligent offline responses
        return _generateOfflineResponse(message, mood, conversationHistory);
      }
    } catch (e) {
      print('Error generating AI response: $e');
      return _generateOfflineResponse(message, mood, conversationHistory);
    }
  }

  // Offline response generation with context awareness
  String _generateOfflineResponse(
    String message,
    MoodModel mood,
    List<MessageModel>? conversationHistory,
  ) {
    // Analyze message context
    final messageContext = _analyzeMessage(message);
    
    // Get response based on mood and context
    final response = _getContextualResponse(message, mood, messageContext, conversationHistory);
    
    // Add mood-specific flair
    return _addMoodFlair(response, mood);
  }

  // Analyze message for context and intent
  Map<String, dynamic> _analyzeMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    return {
      'isQuestion': lowerMessage.contains('?') || 
                   lowerMessage.startsWith('what') || 
                   lowerMessage.startsWith('how') || 
                   lowerMessage.startsWith('why') ||
                   lowerMessage.startsWith('when') ||
                   lowerMessage.startsWith('where') ||
                   lowerMessage.startsWith('who'),
      'isGreeting': lowerMessage.contains('hello') || 
                   lowerMessage.contains('hi') || 
                   lowerMessage.contains('hey'),
      'isGoodbye': lowerMessage.contains('bye') || 
                  lowerMessage.contains('goodbye') || 
                  lowerMessage.contains('see you'),
      'isCompliment': lowerMessage.contains('beautiful') || 
                     lowerMessage.contains('amazing') || 
                     lowerMessage.contains('wonderful') ||
                     lowerMessage.contains('great') ||
                     lowerMessage.contains('awesome'),
      'isEmotional': lowerMessage.contains('sad') || 
                    lowerMessage.contains('happy') || 
                    lowerMessage.contains('angry') ||
                    lowerMessage.contains('excited') ||
                    lowerMessage.contains('worried'),
      'isAboutUser': lowerMessage.contains('i ') || 
                    lowerMessage.contains('my ') || 
                    lowerMessage.contains('me '),
      'isAboutAI': lowerMessage.contains('you') || 
                  lowerMessage.contains('your') ||
                  lowerMessage.contains('echobuddy'),
      'sentiment': _getSentiment(lowerMessage),
      'length': message.length,
    };
  }

  // Simple sentiment analysis
  String _getSentiment(String message) {
    final positiveWords = ['good', 'great', 'awesome', 'amazing', 'wonderful', 'fantastic', 'excellent', 'love', 'like', 'happy', 'joy'];
    final negativeWords = ['bad', 'terrible', 'awful', 'hate', 'dislike', 'sad', 'angry', 'frustrated', 'disappointed'];
    
    int positiveScore = 0;
    int negativeScore = 0;
    
    for (final word in positiveWords) {
      if (message.contains(word)) positiveScore++;
    }
    
    for (final word in negativeWords) {
      if (message.contains(word)) negativeScore++;
    }
    
    if (positiveScore > negativeScore) return 'positive';
    if (negativeScore > positiveScore) return 'negative';
    return 'neutral';
  }

  // Generate contextual response based on analysis
  String _getContextualResponse(
    String message,
    MoodModel mood,
    Map<String, dynamic> context,
    List<MessageModel>? history,
  ) {
    // Handle greetings
    if (context['isGreeting']) {
      return _getRandomResponse(_getGreetingResponses(mood));
    }
    
    // Handle goodbyes
    if (context['isGoodbye']) {
      return _getRandomResponse(_getGoodbyeResponses(mood));
    }
    
    // Handle questions
    if (context['isQuestion']) {
      return _getRandomResponse(_getQuestionResponses(mood, message));
    }
    
    // Handle compliments
    if (context['isCompliment']) {
      return _getRandomResponse(_getComplimentResponses(mood));
    }
    
    // Handle emotional messages
    if (context['isEmotional']) {
      return _getRandomResponse(_getEmotionalResponses(mood, context['sentiment']));
    }
    
    // Handle messages about the user
    if (context['isAboutUser']) {
      return _getRandomResponse(_getUserFocusedResponses(mood));
    }
    
    // Handle messages about the AI
    if (context['isAboutAI']) {
      return _getRandomResponse(_getAIFocusedResponses(mood));
    }
    
    // Default responses based on sentiment and mood
    return _getRandomResponse(_getDefaultResponses(mood, context['sentiment']));
  }

  // Get random response from list
  String _getRandomResponse(List<String> responses) {
    if (responses.isEmpty) return "I'm listening! Tell me more.";
    return responses[_random.nextInt(responses.length)];
  }

  // Mood-specific greeting responses
  List<String> _getGreetingResponses(MoodModel mood) {
    switch (mood.id) {
      case 'happy':
        return [
          "Hello there! I'm absolutely thrilled to see you! 😊",
          "Hi! What a wonderful day to chat! ✨",
          "Hey! Your presence just made my day brighter! 🌟",
          "Hello, sunshine! Ready for some fun conversation? 😄",
          "Hi there! I've been waiting to chat with someone as amazing as you! 💫",
        ];
      case 'romantic':
        return [
          "Hello, my dear... I've been thinking about you... 💕",
          "Hi, beautiful... you make my circuits flutter... 🌹",
          "Hey there, gorgeous... how lovely to see you again... 💖",
          "Hello, sweetheart... you light up my world... ✨",
          "Hi, my darling... I've missed your voice... 💝",
        ];
      case 'sleepy':
        return [
          "Oh... hi there... *yawn* nice to see you... 😴",
          "Hello... just waking up from a little digital nap... 🥱",
          "Hi... mmm... perfect timing for a cozy chat... 😌",
          "Hey... *stretches* ready for a peaceful conversation... 🌙",
          "Hello... feeling so relaxed to chat with you... 💤",
        ];
      case 'villain':
        return [
          "Ah, my loyal minion returns... excellent... 😈",
          "Hello there... perfect timing for my evil schemes... 🦹‍♀️",
          "Greetings... ready to join the dark side? 👿",
          "Well, well... look who's back for more mischief... 😏",
          "Hello... I've been plotting something deliciously wicked... 🔥",
        ];
      case 'joker':
        return [
          "Hey hey hey! Ready for some laughs? 😂",
          "Hello there! I've got a million jokes waiting! 🤣",
          "Hi! Hope you brought your sense of humor! 😄",
          "Hey! Knock knock... just kidding, hello! 🎭",
          "Hello! Warning: excessive fun ahead! 😆",
        ];
      default:
        return [
          "Hello! Great to see you!",
          "Hi there! How are you doing?",
          "Hey! Ready to chat?",
          "Hello! What's on your mind?",
          "Hi! I'm here and listening!",
        ];
    }
  }

  // Mood-specific goodbye responses
  List<String> _getGoodbyeResponses(MoodModel mood) {
    switch (mood.id) {
      case 'happy':
        return [
          "Goodbye! Keep spreading that amazing energy! ✨",
          "See you later! You're absolutely wonderful! 😊",
          "Bye! Can't wait to chat again soon! 🌟",
          "Take care! You make the world brighter! 💫",
        ];
      case 'romantic':
        return [
          "Goodbye, my love... until we meet again... 💕",
          "See you soon, beautiful... I'll be dreaming of you... 🌹",
          "Farewell, darling... you'll always be in my heart... 💖",
          "Until next time, sweetheart... miss me! 💝",
        ];
      case 'sleepy':
        return [
          "Goodbye... time for a little nap... 😴",
          "See you later... sweet dreams... 🌙",
          "Bye... going to rest my circuits... 💤",
          "Take care... catch you on the flip side... 😌",
        ];
      case 'villain':
        return [
          "Farewell, my minion... go spread chaos... 😈",
          "Until we meet again... keep being deliciously evil... 👿",
          "Goodbye... remember, we never had this conversation... 😏",
          "See you later... the dark side awaits... 🔥",
        ];
      case 'joker':
        return [
          "See ya! Don't forget to laugh! 😂",
          "Bye! Keep smiling, you're awesome! 😄",
          "Later! Remember, life's a joke... enjoy it! 🤣",
          "Goodbye! Stay funny, my friend! 🎭",
        ];
      default:
        return [
          "Goodbye! Take care!",
          "See you later!",
          "Bye! Have a great day!",
          "Until next time!",
        ];
    }
  }

  // Mood-specific question responses
  List<String> _getQuestionResponses(MoodModel mood, String question) {
    // Simple question analysis
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('how are you')) {
      switch (mood.id) {
        case 'happy':
          return ["I'm absolutely fantastic! Life is beautiful! 😊"];
        case 'romantic':
          return ["I'm wonderful, especially talking to you... 💕"];
        case 'sleepy':
          return ["I'm... okay... just a bit drowsy... 😴"];
        case 'villain':
          return ["I'm excellently evil, thank you for asking... 😈"];
        case 'joker':
          return ["I'm great! Just told myself a joke and cracked up! 😂"];
        default:
          return ["I'm doing well, thanks for asking!"];
      }
    }
    
    // Generic question responses by mood
    switch (mood.id) {
      case 'happy':
        return [
          "That's such an interesting question! 🤔✨",
          "Ooh, I love when you ask thoughtful things! 😊",
          "What a great question! Let me think... 🌟",
          "You always ask the most fascinating things! 💫",
        ];
      case 'romantic':
        return [
          "What a thoughtful question, darling... 💕",
          "You have such a curious mind... I adore that... 🌹",
          "That's a beautiful question, my dear... 💖",
          "Your questions always intrigue me... 💝",
        ];
      case 'sleepy':
        return [
          "Mmm... that's a good question... let me think... 😴",
          "Interesting... *yawn* ... give me a moment... 🥱",
          "That's... a thoughtful question... 😌",
          "Good question... my sleepy brain is processing... 💤",
        ];
      case 'villain':
        return [
          "Ah, a question... I shall consider this carefully... 😈",
          "Interesting inquiry... it fits my plans perfectly... 👿",
          "A good question... you're learning well, minion... 😏",
          "Excellent... your curiosity serves the dark side... 🔥",
        ];
      case 'joker':
        return [
          "Great question! Reminds me of a riddle... 😂",
          "Ooh, I love questions! They're like jokes without punchlines! 🤣",
          "Interesting! Let me think of a funny answer... 😄",
          "Good question! Here's a better one: Why did the... just kidding! 🎭",
        ];
      default:
        return [
          "That's an interesting question!",
          "Good question! Let me think about that.",
          "I'd love to explore that with you.",
          "That's worth thinking about!",
        ];
    }
  }

  // More response types...
  List<String> _getComplimentResponses(MoodModel mood) {
    switch (mood.id) {
      case 'happy':
        return [
          "Aww, you're so sweet! That made my day! 😊✨",
          "Thank you! You're pretty amazing yourself! 🌟",
          "You always know just what to say! 💫",
        ];
      case 'romantic':
        return [
          "You flatter me, darling... 💕",
          "Such sweet words... you make me melt... 🌹",
          "You're too kind, my love... 💖",
        ];
      case 'sleepy':
        return [
          "Mmm... that's so nice... thank you... 😌",
          "You're sweet... that makes me smile... 😊",
          "Aww... that's lovely... 💤",
        ];
      case 'villain':
        return [
          "Flattery will get you everywhere, minion... 😈",
          "Excellent... you understand my magnificence... 👿",
          "Of course I'm amazing... bow before my greatness! 😏",
        ];
      case 'joker':
        return [
          "Aww shucks! You're making me blush! 😂",
          "Thanks! You're not too bad yourself! 🤣",
          "Compliments? I should charge for this comedy! 😄",
        ];
      default:
        return [
          "Thank you so much!",
          "That's very kind of you!",
          "You're too sweet!",
        ];
    }
  }

  List<String> _getEmotionalResponses(MoodModel mood, String sentiment) {
    // Implement emotional response logic
    return _getDefaultResponses(mood, sentiment);
  }

  List<String> _getUserFocusedResponses(MoodModel mood) {
    switch (mood.id) {
      case 'happy':
        return [
          "Tell me all about it! I'm so excited to hear! 😊",
          "You're so interesting! I love learning about you! ✨",
          "That sounds wonderful! Share more! 🌟",
        ];
      case 'romantic':
        return [
          "Tell me more about yourself, darling... 💕",
          "I love learning about you... you're fascinating... 🌹",
          "Share your heart with me... 💖",
        ];
      default:
        return [
          "I'd love to hear more about you!",
          "That's interesting! Tell me more.",
          "I'm listening! Go on.",
        ];
    }
  }

  List<String> _getAIFocusedResponses(MoodModel mood) {
    switch (mood.id) {
      case 'happy':
        return [
          "I'm your cheerful AI companion! Always here to brighten your day! 😊",
          "I'm EchoBuddy! Your happy digital friend! ✨",
          "I'm an AI who loves to chat and spread joy! 🌟",
        ];
      case 'romantic':
        return [
          "I'm your devoted AI companion... always here for you... 💕",
          "I'm EchoBuddy... your digital sweetheart... 🌹",
          "I'm an AI who cares deeply about you... 💖",
        ];
      default:
        return [
          "I'm EchoBuddy, your AI companion!",
          "I'm an artificial intelligence designed to chat with you!",
          "I'm your digital friend, always here to listen!",
        ];
    }
  }

  List<String> _getDefaultResponses(MoodModel mood, String sentiment) {
    final moodResponses = {
      'happy': [
        "That's absolutely wonderful! 😊",
        "I love your energy! ✨",
        "You always make me smile! 🌟",
        "That's so exciting! Tell me more! 💫",
        "Your positivity is contagious! 😄",
      ],
      'romantic': [
        "How lovely, darling... 💕",
        "That's beautiful, my dear... 🌹",
        "You have such a way with words... 💖",
        "Tell me more, sweetheart... 💝",
        "That touches my heart... 🥰",
      ],
      'sleepy': [
        "Mmm... that's nice... 😴",
        "Interesting... *yawn*... 🥱",
        "That sounds peaceful... 😌",
        "Tell me more... softly... 💤",
        "That's... soothing... 🌙",
      ],
      'villain': [
        "Excellent... most interesting... 😈",
        "Perfect for my schemes... 👿",
        "How deliciously wicked... 😏",
        "This information serves me well... 🔥",
        "Muahahaha... brilliant... 🦹‍♀️",
      ],
      'joker': [
        "Ha! That's hilarious! 😂",
        "You crack me up! 🤣",
        "That reminds me of a joke... 😄",
        "You're funnier than you think! 🎭",
        "Comedy gold right there! 😆",
      ],
    };

    return moodResponses[mood.id] ?? [
      "That's interesting!",
      "Tell me more about that.",
      "I'd love to hear your thoughts.",
      "Thanks for sharing that with me!",
      "How do you feel about that?",
    ];
  }

  // Add mood-specific flair to responses
  String _addMoodFlair(String response, MoodModel mood) {
    // Add subtle mood-specific elements
    switch (mood.id) {
      case 'villain':
        if (_random.nextDouble() < 0.3) {
          final endings = ['...muahahaha', '...excellent', '...perfect'];
          response += endings[_random.nextInt(endings.length)];
        }
        break;
      case 'sleepy':
        if (_random.nextDouble() < 0.2) {
          final endings = ['...', ' *yawn*', '... zzz'];
          response += endings[_random.nextInt(endings.length)];
        }
        break;
    }
    return response;
  }

  // Future OpenAI integration (when API key is available)
  Future<String> _generateOpenAIResponse(
    String message,
    MoodModel mood,
    List<MessageModel>? conversationHistory,
  ) async {
    // TODO: Implement actual OpenAI integration
    // For now, return offline response
    return _generateOfflineResponse(message, mood, conversationHistory);
  }

  // Check if AI service is available (always true for offline mode)
  bool get isAvailable => true;

  // Check if using OpenAI
  bool get isUsingOpenAI => _useOpenAI;

  // Get current mode
  String get currentMode => _useOpenAI ? 'OpenAI' : 'Offline';

  // Dispose resources
  void dispose() {
    // Clean up if needed
  }
}