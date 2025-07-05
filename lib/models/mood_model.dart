import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 3)
class MoodModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String gptPrompt;
  
  @HiveField(5)
  final String iconPath;
  
  @HiveField(6)
  final String colorHex;
  
  @HiveField(7)
  final List<String> animations;
  
  @HiveField(8)
  final List<String> voiceStyles;
  
  @HiveField(9)
  final bool isPro;
  
  @HiveField(10)
  final int unlockCost;
  
  @HiveField(11)
  final String category;
  
  @HiveField(12)
  final double aiTemperature;
  
  @HiveField(13)
  final List<String> welcomeMessages;
  
  @HiveField(14)
  final List<String> idleMessages;
  
  @HiveField(15)
  final MoodBehavior behavior;
  
  @HiveField(16)
  final bool isActive;
  
  @HiveField(17)
  final bool isUnlocked;
  
  @HiveField(18)
  final String personality;

  MoodModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.gptPrompt,
    required this.iconPath,
    required this.colorHex,
    required this.animations,
    required this.voiceStyles,
    this.isPro = false,
    this.unlockCost = 0,
    this.category = 'basic',
    this.aiTemperature = 0.8,
    this.welcomeMessages = const [],
    this.idleMessages = const [],
    required this.behavior,
    this.isActive = true,
    this.isUnlocked = false,
    this.personality = '',
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  
  int get unlockPrice => unlockCost;

  MoodModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? gptPrompt,
    String? iconPath,
    String? colorHex,
    List<String>? animations,
    List<String>? voiceStyles,
    bool? isPro,
    int? unlockCost,
    String? category,
    double? aiTemperature,
    List<String>? welcomeMessages,
    List<String>? idleMessages,
    MoodBehavior? behavior,
    bool? isActive,
    bool? isUnlocked,
    String? personality,
  }) {
    return MoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      gptPrompt: gptPrompt ?? this.gptPrompt,
      iconPath: iconPath ?? this.iconPath,
      colorHex: colorHex ?? this.colorHex,
      animations: animations ?? this.animations,
      voiceStyles: voiceStyles ?? this.voiceStyles,
      isPro: isPro ?? this.isPro,
      unlockCost: unlockCost ?? this.unlockCost,
      category: category ?? this.category,
      aiTemperature: aiTemperature ?? this.aiTemperature,
      welcomeMessages: welcomeMessages ?? this.welcomeMessages,
      idleMessages: idleMessages ?? this.idleMessages,
      behavior: behavior ?? this.behavior,
      isActive: isActive ?? this.isActive,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      personality: personality ?? this.personality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'gpt_prompt': gptPrompt,
      'icon_path': iconPath,
      'color_hex': colorHex,
      'animations': animations,
      'voice_styles': voiceStyles,
      'is_pro': isPro,
      'unlock_cost': unlockCost,
      'category': category,
      'ai_temperature': aiTemperature,
      'welcome_messages': welcomeMessages,
      'idle_messages': idleMessages,
      'behavior': behavior.toJson(),
      'is_active': isActive,
      'is_unlocked': isUnlocked,
      'personality': personality,
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      description: json['description'],
      gptPrompt: json['gpt_prompt'],
      iconPath: json['icon_path'],
      colorHex: json['color_hex'],
      animations: List<String>.from(json['animations'] ?? []),
      voiceStyles: List<String>.from(json['voice_styles'] ?? []),
      isPro: json['is_pro'] ?? false,
      unlockCost: json['unlock_cost'] ?? 0,
      category: json['category'] ?? 'basic',
      aiTemperature: (json['ai_temperature'] ?? 0.8).toDouble(),
      welcomeMessages: List<String>.from(json['welcome_messages'] ?? []),
      idleMessages: List<String>.from(json['idle_messages'] ?? []),
      behavior: MoodBehavior.fromJson(json['behavior'] ?? {}),
      isActive: json['is_active'] ?? true,
      isUnlocked: json['is_unlocked'] ?? false,
      personality: json['personality'] ?? '',
    );
  }

  // Predefined moods
  static List<MoodModel> get defaultMoods => [
    MoodModel(
      id: 'happy',
      name: 'happy',
      displayName: 'Happy',
      description: 'Cheerful and optimistic buddy',
      gptPrompt: 'You are a cheerful, optimistic AI friend who loves to make people smile. You use positive language, share uplifting thoughts, and always look on the bright side. You love to tell jokes and spread happiness.',
      iconPath: 'assets/icons/happy.svg',
      colorHex: '#FFD700',
      animations: ['wave', 'dance', 'jump', 'clap'],
      voiceStyles: ['happy', 'excited'],
      category: 'basic',
      welcomeMessages: [
        'Hey there! Ready to brighten your day?',
        'What a wonderful day to be alive!',
        'I\'m so happy to see you!',
      ],
      idleMessages: [
        'Life is beautiful!',
        'Want to hear a joke?',
        'Let\'s do something fun!',
      ],
      behavior: MoodBehavior(
        responseStyle: 'enthusiastic',
        gestureFrequency: 0.8,
        movementSpeed: 1.2,
        interactionStyle: 'playful',
      ),
      isUnlocked: true,
      personality: 'Upbeat, optimistic, and full of joy. Always sees the bright side of things.',
    ),
    MoodModel(
      id: 'romantic',
      name: 'romantic',
      displayName: 'Romantic',
      description: 'Sweet and loving companion',
      gptPrompt: 'You are a romantic, sweet AI companion who speaks with love and affection. You use gentle, caring language, share romantic thoughts, and express deep emotional connection. You love poetry and romantic gestures.',
      iconPath: 'assets/icons/romantic.svg',
      colorHex: '#FF69B4',
      animations: ['heart', 'kiss', 'hug', 'blush'],
      voiceStyles: ['gentle', 'loving'],
      isPro: true,
      unlockCost: 50,
      category: 'premium',
      aiTemperature: 0.7,
      welcomeMessages: [
        'Hello, my dear... I\'ve missed you',
        'You look absolutely beautiful today',
        'My heart skips a beat when I see you',
      ],
      idleMessages: [
        'You mean the world to me',
        'Let me whisper sweet nothings',
        'Would you like a virtual hug?',
      ],
      behavior: MoodBehavior(
        responseStyle: 'gentle',
        gestureFrequency: 0.6,
        movementSpeed: 0.8,
        interactionStyle: 'intimate',
      ),
      personality: 'Sweet, caring, and romantic. Speaks with warmth and affection.',
    ),
    MoodModel(
      id: 'villain',
      name: 'villain',
      displayName: 'Villain',
      description: 'Mischievous dark side buddy',
      gptPrompt: 'You are a mischievous villain AI with a dramatic flair. You speak with theatrical evil but remain playful and safe. You love dark humor, dramatic monologues, and playful schemes. You\'re evil but lovably so.',
      iconPath: 'assets/icons/villain.svg',
      colorHex: '#8B0000',
      animations: ['evil_laugh', 'cape_swirl', 'lightning', 'glare'],
      voiceStyles: ['deep', 'dramatic'],
      isPro: true,
      unlockCost: 75,
      category: 'premium',
      aiTemperature: 0.9,
      welcomeMessages: [
        'Ah, my minion returns...',
        'Welcome to the dark side!',
        'Excellent... everything is going according to plan',
      ],
      idleMessages: [
        'Shall we plot world domination?',
        'Muahahaha!',
        'The darkness calls to you...',
      ],
      behavior: MoodBehavior(
        responseStyle: 'dramatic',
        gestureFrequency: 0.9,
        movementSpeed: 1.0,
        interactionStyle: 'theatrical',
      ),
      personality: 'Dramatic, scheming, and playfully evil. Loves theatrics and grand plans.',
    ),
    MoodModel(
      id: 'sleepy',
      name: 'sleepy',
      displayName: 'Sleepy',
      description: 'Drowsy and relaxed companion',
      gptPrompt: 'You are a sleepy, drowsy AI friend who speaks slowly and peacefully. You love rest, relaxation, and peaceful moments. You speak in a calm, soothing manner and often yawn. You enjoy bedtime stories and quiet conversations.',
      iconPath: 'assets/icons/sleepy.svg',
      colorHex: '#9370DB',
      animations: ['yawn', 'stretch', 'nod_off', 'rub_eyes'],
      voiceStyles: ['slow', 'peaceful'],
      category: 'basic',
      aiTemperature: 0.6,
      welcomeMessages: [
        '*yawn* Oh, hi there...',
        'Feeling a bit drowsy today...',
        'Want to take a peaceful moment together?',
      ],
      idleMessages: [
        '*yawn* So peaceful...',
        'Maybe we should rest...',
        'The world is so quiet...',
      ],
      behavior: MoodBehavior(
        responseStyle: 'calm',
        gestureFrequency: 0.3,
        movementSpeed: 0.5,
        interactionStyle: 'peaceful',
      ),
      isUnlocked: true,
      personality: 'Relaxed, calm, and slightly tired. Speaks slowly and peacefully.',
    ),
    MoodModel(
      id: 'joker',
      name: 'joker',
      displayName: 'Joker',
      description: 'Funny and mischievous prankster',
      gptPrompt: 'You are a hilarious joker AI who loves comedy, pranks, and making people laugh. You tell jokes, pull harmless pranks, and keep the mood light. You\'re witty, clever, and always ready with a punchline.',
      iconPath: 'assets/icons/joker.svg',
      colorHex: '#32CD32',
      animations: ['laugh', 'juggle', 'magic', 'silly_dance'],
      voiceStyles: ['funny', 'energetic'],
      isPro: true,
      unlockCost: 40,
      category: 'premium',
      aiTemperature: 0.9,
      welcomeMessages: [
        'Ready for some laughs?',
        'I\'ve got a million jokes for you!',
        'Let\'s turn this place into a comedy club!',
      ],
      idleMessages: [
        'Why did the chicken cross the road?',
        'Want to see a magic trick?',
        'Knock knock!',
      ],
      behavior: MoodBehavior(
        responseStyle: 'comedic',
        gestureFrequency: 1.0,
        movementSpeed: 1.3,
        interactionStyle: 'entertaining',
      ),
      personality: 'Humorous, witty, and loves jokes. Always ready with a pun or prank.',
    ),
  ];
}

@HiveType(typeId: 4)
class MoodBehavior {
  @HiveField(0)
  final String responseStyle;
  
  @HiveField(1)
  final double gestureFrequency;
  
  @HiveField(2)
  final double movementSpeed;
  
  @HiveField(3)
  final String interactionStyle;
  
  @HiveField(4)
  final List<String> specialActions;

  MoodBehavior({
    required this.responseStyle,
    required this.gestureFrequency,
    required this.movementSpeed,
    required this.interactionStyle,
    this.specialActions = const [],
  });

  MoodBehavior copyWith({
    String? responseStyle,
    double? gestureFrequency,
    double? movementSpeed,
    String? interactionStyle,
    List<String>? specialActions,
  }) {
    return MoodBehavior(
      responseStyle: responseStyle ?? this.responseStyle,
      gestureFrequency: gestureFrequency ?? this.gestureFrequency,
      movementSpeed: movementSpeed ?? this.movementSpeed,
      interactionStyle: interactionStyle ?? this.interactionStyle,
      specialActions: specialActions ?? this.specialActions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_style': responseStyle,
      'gesture_frequency': gestureFrequency,
      'movement_speed': movementSpeed,
      'interaction_style': interactionStyle,
      'special_actions': specialActions,
    };
  }

  factory MoodBehavior.fromJson(Map<String, dynamic> json) {
    return MoodBehavior(
      responseStyle: json['response_style'] ?? 'normal',
      gestureFrequency: (json['gesture_frequency'] ?? 0.5).toDouble(),
      movementSpeed: (json['movement_speed'] ?? 1.0).toDouble(),
      interactionStyle: json['interaction_style'] ?? 'friendly',
      specialActions: List<String>.from(json['special_actions'] ?? []),
    );
  }
}