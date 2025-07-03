import 'package:hive/hive.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 7)
class ConversationModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final List<MessageModel> messages;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final String mood;
  
  @HiveField(6)
  final String outfit;
  
  @HiveField(7)
  final ConversationContext context;
  
  @HiveField(8)
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.userId,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
    this.mood = 'happy',
    this.outfit = 'default',
    required this.context,
    this.isActive = true,
  });

  ConversationModel copyWith({
    String? id,
    String? userId,
    List<MessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mood,
    String? outfit,
    ConversationContext? context,
    bool? isActive,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      outfit: outfit ?? this.outfit,
      context: context ?? this.context,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mood': mood,
      'outfit': outfit,
      'context': context.toJson(),
      'is_active': isActive,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      userId: json['user_id'],
      messages: (json['messages'] as List?)
          ?.map((m) => MessageModel.fromJson(m))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mood: json['mood'] ?? 'happy',
      outfit: json['outfit'] ?? 'default',
      context: ConversationContext.fromJson(json['context'] ?? {}),
      isActive: json['is_active'] ?? true,
    );
  }

  MessageModel? get lastMessage => messages.isNotEmpty ? messages.last : null;
  
  int get messageCount => messages.length;
  
  Duration get totalDuration {
    return messages.fold(Duration.zero, (total, message) {
      return total + (message.duration ?? Duration.zero);
    });
  }
}

@HiveType(typeId: 8)
class MessageModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String content;
  
  @HiveField(2)
  final MessageType type;
  
  @HiveField(3)
  final MessageSender sender;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String? audioPath;
  
  @HiveField(6)
  final Duration? duration;
  
  @HiveField(7)
  final List<String> animations;
  
  @HiveField(8)
  final MessageMetadata metadata;
  
  @HiveField(9)
  final bool isMemory;
  
  @HiveField(10)
  final String? replyToId;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.audioPath,
    this.duration,
    this.animations = const [],
    required this.metadata,
    this.isMemory = false,
    this.replyToId,
  });

  MessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    String? audioPath,
    Duration? duration,
    List<String>? animations,
    MessageMetadata? metadata,
    bool? isMemory,
    String? replyToId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      animations: animations ?? this.animations,
      metadata: metadata ?? this.metadata,
      isMemory: isMemory ?? this.isMemory,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'audio_path': audioPath,
      'duration': duration?.inSeconds,
      'animations': animations,
      'metadata': metadata.toJson(),
      'is_memory': isMemory,
      'reply_to_id': replyToId,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      sender: MessageSender.values.firstWhere(
        (s) => s.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      audioPath: json['audio_path'],
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      animations: List<String>.from(json['animations'] ?? []),
      metadata: MessageMetadata.fromJson(json['metadata'] ?? {}),
      isMemory: json['is_memory'] ?? false,
      replyToId: json['reply_to_id'],
    );
  }

  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;
  bool get hasAnimations => animations.isNotEmpty;
}

@HiveType(typeId: 9)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  voice,
  @HiveField(2)
  system,
  @HiveField(3)
  command,
  @HiveField(4)
  memory,
  @HiveField(5)
  emotion,
  @HiveField(6)
  action,
}

@HiveType(typeId: 10)
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  ai,
  @HiveField(2)
  system,
}

@HiveType(typeId: 11)
class MessageMetadata {
  @HiveField(0)
  final String mood;
  
  @HiveField(1)
  final String outfit;
  
  @HiveField(2)
  final double confidence;
  
  @HiveField(3)
  final List<String> tags;
  
  @HiveField(4)
  final Map<String, dynamic> extra;
  
  @HiveField(5)
  final String? voiceStyle;
  
  @HiveField(6)
  final bool isSpecialCommand;

  MessageMetadata({
    this.mood = 'happy',
    this.outfit = 'default',
    this.confidence = 1.0,
    this.tags = const [],
    this.extra = const {},
    this.voiceStyle,
    this.isSpecialCommand = false,
  });

  MessageMetadata copyWith({
    String? mood,
    String? outfit,
    double? confidence,
    List<String>? tags,
    Map<String, dynamic>? extra,
    String? voiceStyle,
    bool? isSpecialCommand,
  }) {
    return MessageMetadata(
      mood: mood ?? this.mood,
      outfit: outfit ?? this.outfit,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
      extra: extra ?? this.extra,
      voiceStyle: voiceStyle ?? this.voiceStyle,
      isSpecialCommand: isSpecialCommand ?? this.isSpecialCommand,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'outfit': outfit,
      'confidence': confidence,
      'tags': tags,
      'extra': extra,
      'voice_style': voiceStyle,
      'is_special_command': isSpecialCommand,
    };
  }

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      mood: json['mood'] ?? 'happy',
      outfit: json['outfit'] ?? 'default',
      confidence: (json['confidence'] ?? 1.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      extra: Map<String, dynamic>.from(json['extra'] ?? {}),
      voiceStyle: json['voice_style'],
      isSpecialCommand: json['is_special_command'] ?? false,
    );
  }
}

@HiveType(typeId: 12)
class ConversationContext {
  @HiveField(0)
  final List<String> recentTopics;
  
  @HiveField(1)
  final Map<String, String> userPreferences;
  
  @HiveField(2)
  final List<String> activeMemories;
  
  @HiveField(3)
  final String currentActivity;
  
  @HiveField(4)
  final Map<String, dynamic> sessionData;

  ConversationContext({
    this.recentTopics = const [],
    this.userPreferences = const {},
    this.activeMemories = const [],
    this.currentActivity = 'chat',
    this.sessionData = const {},
  });

  ConversationContext copyWith({
    List<String>? recentTopics,
    Map<String, String>? userPreferences,
    List<String>? activeMemories,
    String? currentActivity,
    Map<String, dynamic>? sessionData,
  }) {
    return ConversationContext(
      recentTopics: recentTopics ?? this.recentTopics,
      userPreferences: userPreferences ?? this.userPreferences,
      activeMemories: activeMemories ?? this.activeMemories,
      currentActivity: currentActivity ?? this.currentActivity,
      sessionData: sessionData ?? this.sessionData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recent_topics': recentTopics,
      'user_preferences': userPreferences,
      'active_memories': activeMemories,
      'current_activity': currentActivity,
      'session_data': sessionData,
    };
  }

  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      recentTopics: List<String>.from(json['recent_topics'] ?? []),
      userPreferences: Map<String, String>.from(json['user_preferences'] ?? {}),
      activeMemories: List<String>.from(json['active_memories'] ?? []),
      currentActivity: json['current_activity'] ?? 'chat',
      sessionData: Map<String, dynamic>.from(json['session_data'] ?? {}),
    );
  }
}