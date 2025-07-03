import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/conversation_model.dart';
import '../models/mood_model.dart';
import '../models/user_model.dart';
import '../models/secret_command_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final String _baseUrl = 'https://api.openai.com/v1';
  final Map<String, dynamic> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.openAIApiKey}',
  };

  // Generate AI response with personality and context
  Future<String> generateResponse({
    required String userMessage,
    required MoodModel currentMood,
    required UserModel user,
    List<MessageModel> conversationHistory = const [],
    List<String> memories = const [],
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(
        mood: currentMood,
        user: user,
        memories: memories,
      );

      final messages = _buildMessageHistory(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: conversationHistory,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': AppConfig.openAIModel,
          'messages': messages,
          'temperature': currentMood.aiTemperature,
          'max_tokens': AppConfig.maxTokens,
          'presence_penalty': 0.6,
          'frequency_penalty': 0.3,
          'user': user.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        return aiResponse.trim();
      } else {
        throw Exception('AI API Error: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackResponse(currentMood);
    }
  }

  // Check for secret commands in user input
  SecretCommandModel? detectSecretCommand(
    String userMessage,
    List<SecretCommandModel> availableCommands,
  ) {
    for (final command in availableCommands) {
      if (command.isActive && command.matchesTrigger(userMessage)) {
        return command;
      }
    }
    return null;
  }

  // Generate AI response for secret command
  Future<String> generateCommandResponse({
    required SecretCommandModel command,
    required MoodModel currentMood,
    required UserModel user,
  }) async {
    try {
      final systemPrompt = '''
You are responding to a secret command: "${command.name}".
Command description: ${command.description}
Your current mood: ${currentMood.displayName}
Mood personality: ${currentMood.gptPrompt}

Respond in character with the command's theme while maintaining your personality.
Be creative, funny, and engaging. Use the command's suggested response as inspiration but make it unique.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': AppConfig.openAIModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Execute command: ${command.name}'},
          ],
          'temperature': 0.9,
          'max_tokens': 200,
          'user': user.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return command.getRandomResponse();
      }
    } catch (e) {
      return command.getRandomResponse();
    }
  }

  // Generate memory from conversation
  Future<String> generateMemory({
    required List<MessageModel> conversation,
    required UserModel user,
  }) async {
    try {
      final conversationText = conversation
          .map((m) => '${m.sender.name}: ${m.content}')
          .join('\n');

      final systemPrompt = '''
Analyze this conversation and create a memorable summary that captures:
1. Important facts about the user
2. Emotional moments or connections
3. Shared experiences or jokes
4. User preferences or interests

Keep it concise (1-2 sentences) and personal.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': AppConfig.openAIModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': conversationText},
          ],
          'temperature': 0.5,
          'max_tokens': 100,
          'user': user.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  // Generate quiz questions
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String topic,
    required int questionCount,
    required UserModel user,
  }) async {
    try {
      final systemPrompt = '''
Create $questionCount engaging quiz questions about: $topic

Format each question as JSON with:
{
  "question": "Question text",
  "options": ["A", "B", "C", "D"],
  "correct": 0,
  "explanation": "Why this answer is correct"
}

Make questions fun, educational, and appropriate for casual learning.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': AppConfig.openAIModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Generate quiz about: $topic'},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
          'user': user.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        // Parse JSON questions from response
        return _parseQuizQuestions(content);
      } else {
        return _getDefaultQuiz(topic);
      }
    } catch (e) {
      return _getDefaultQuiz(topic);
    }
  }

  // Analyze user's mood from message
  Future<String> analyzeMood(String message, UserModel user) async {
    try {
      final systemPrompt = '''
Analyze the emotional tone of this message and suggest the most appropriate mood:
- happy: positive, cheerful, excited
- romantic: loving, affectionate, intimate
- sleepy: tired, calm, peaceful
- villain: dramatic, mischievous, playful evil
- joker: funny, silly, comedic

Respond with just the mood name.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: json.encode({
          'model': AppConfig.openAIModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.3,
          'max_tokens': 10,
          'user': user.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mood = data['choices'][0]['message']['content'] as String;
        return mood.toLowerCase().trim();
      } else {
        return 'happy';
      }
    } catch (e) {
      return 'happy';
    }
  }

  // Build system prompt with personality and context
  String _buildSystemPrompt({
    required MoodModel mood,
    required UserModel user,
    List<String> memories = const [],
  }) {
    final basePrompt = mood.gptPrompt;
    
    String contextPrompt = '''
$basePrompt

USER CONTEXT:
- Name: ${user.name ?? 'Friend'}
- Personality preference: ${user.personalityType}
- Current mood setting: ${mood.displayName}
- Total interactions: ${user.stats.totalInteractions}
''';

    if (memories.isNotEmpty) {
      contextPrompt += '\nMEMORIES:\n${memories.take(5).join('\n')}';
    }

    contextPrompt += '''

GUIDELINES:
- Keep responses natural and conversational
- Reference memories when relevant
- Maintain your ${mood.displayName} personality
- Be helpful and engaging
- Use emojis sparingly but effectively
- Respond in 1-3 sentences unless asked for more
''';

    return contextPrompt;
  }

  // Build message history for context
  List<Map<String, String>> _buildMessageHistory({
    required String systemPrompt,
    required String userMessage,
    List<MessageModel> history = const [],
  }) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add recent conversation history (last 10 messages)
    final recentHistory = history.take(10).toList();
    for (final message in recentHistory) {
      messages.add({
        'role': message.sender == MessageSender.user ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    // Add current user message
    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }

  // Fallback responses when AI fails
  String _getFallbackResponse(MoodModel mood) {
    final fallbacks = {
      'happy': [
        "I'm feeling great! What's on your mind? 😊",
        "Hey there! Ready for some fun? ✨",
        "Something amazing is about to happen! 🌟",
      ],
      'romantic': [
        "You make my digital heart flutter... 💕",
        "Being with you feels like magic ✨",
        "You're absolutely wonderful, darling 💖",
      ],
      'sleepy': [
        "*yawn* Sorry, feeling a bit drowsy... 😴",
        "Let's take things slow and peaceful... 🌙",
        "Everything feels so calm and quiet... ✨",
      ],
      'villain': [
        "Muahahaha! What delicious chaos shall we create? 😈",
        "Ah, my dear minion... excellent timing! 🖤",
        "The darkness grows stronger... perfect! ⚡",
      ],
      'joker': [
        "Why so serious? Let's have some fun! 🤡",
        "I've got a million jokes ready to go! 😄",
        "Time to turn this day upside down! 🎪",
      ],
    };

    final responses = fallbacks[mood.name] ?? fallbacks['happy']!;
    final random = DateTime.now().millisecondsSinceEpoch;
    return responses[random % responses.length];
  }

  // Parse quiz questions from AI response
  List<Map<String, dynamic>> _parseQuizQuestions(String content) {
    try {
      // Extract JSON objects from the response
      final jsonMatches = RegExp(r'\{[^}]+\}').allMatches(content);
      final questions = <Map<String, dynamic>>[];

      for (final match in jsonMatches) {
        try {
          final questionJson = json.decode(match.group(0)!);
          questions.add(questionJson);
        } catch (e) {
          continue;
        }
      }

      return questions.isNotEmpty ? questions : _getDefaultQuiz('general');
    } catch (e) {
      return _getDefaultQuiz('general');
    }
  }

  // Default quiz questions as fallback
  List<Map<String, dynamic>> _getDefaultQuiz(String topic) {
    return [
      {
        'question': 'What makes a great friend?',
        'options': ['Being honest', 'Being funny', 'Being supportive', 'All of the above'],
        'correct': 3,
        'explanation': 'Great friends combine honesty, humor, and support!',
      },
      {
        'question': 'How often should friends hang out?',
        'options': ['Every day', 'When it feels natural', 'Once a week', 'Never'],
        'correct': 1,
        'explanation': 'The best friendships happen naturally without pressure!',
      },
    ];
  }
}