import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? name;
  
  @HiveField(2)
  final String? email;
  
  @HiveField(3)
  final String? avatarUrl;
  
  @HiveField(4)
  final int coins;
  
  @HiveField(5)
  final bool isPro;
  
  @HiveField(6)
  final DateTime? proExpiryDate;
  
  @HiveField(7)
  final String currentMood;
  
  @HiveField(8)
  final String currentOutfit;
  
  @HiveField(9)
  final List<String> unlockedMoods;
  
  @HiveField(10)
  final List<String> unlockedOutfits;
  
  @HiveField(11)
  final UserPreferences preferences;
  
  @HiveField(12)
  final UserStats stats;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime lastLogin;
  
  @HiveField(15)
  final String personalityType;
  
  @HiveField(16)
  final List<String> memories;
  
  @HiveField(17)
  final int dailyInteractionCount;
  
  @HiveField(18)
  final DateTime? lastDailyLogin;

  UserModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.coins = 0,
    this.isPro = false,
    this.proExpiryDate,
    this.currentMood = 'happy',
    this.currentOutfit = 'default',
    this.unlockedMoods = const ['happy'],
    this.unlockedOutfits = const ['default'],
    required this.preferences,
    required this.stats,
    required this.createdAt,
    required this.lastLogin,
    this.personalityType = 'funny',
    this.memories = const [],
    this.dailyInteractionCount = 0,
    this.lastDailyLogin,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? coins,
    bool? isPro,
    DateTime? proExpiryDate,
    String? currentMood,
    String? currentOutfit,
    List<String>? unlockedMoods,
    List<String>? unlockedOutfits,
    UserPreferences? preferences,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? personalityType,
    List<String>? memories,
    int? dailyInteractionCount,
    DateTime? lastDailyLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coins: coins ?? this.coins,
      isPro: isPro ?? this.isPro,
      proExpiryDate: proExpiryDate ?? this.proExpiryDate,
      currentMood: currentMood ?? this.currentMood,
      currentOutfit: currentOutfit ?? this.currentOutfit,
      unlockedMoods: unlockedMoods ?? this.unlockedMoods,
      unlockedOutfits: unlockedOutfits ?? this.unlockedOutfits,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      personalityType: personalityType ?? this.personalityType,
      memories: memories ?? this.memories,
      dailyInteractionCount: dailyInteractionCount ?? this.dailyInteractionCount,
      lastDailyLogin: lastDailyLogin ?? this.lastDailyLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'coins': coins,
      'is_pro': isPro,
      'pro_expiry_date': proExpiryDate?.toIso8601String(),
      'current_mood': currentMood,
      'current_outfit': currentOutfit,
      'unlocked_moods': unlockedMoods,
      'unlocked_outfits': unlockedOutfits,
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'personality_type': personalityType,
      'memories': memories,
      'daily_interaction_count': dailyInteractionCount,
      'last_daily_login': lastDailyLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      coins: json['coins'] ?? 0,
      isPro: json['is_pro'] ?? false,
      proExpiryDate: json['pro_expiry_date'] != null 
          ? DateTime.parse(json['pro_expiry_date'])
          : null,
      currentMood: json['current_mood'] ?? 'happy',
      currentOutfit: json['current_outfit'] ?? 'default',
      unlockedMoods: List<String>.from(json['unlocked_moods'] ?? ['happy']),
      unlockedOutfits: List<String>.from(json['unlocked_outfits'] ?? ['default']),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: DateTime.parse(json['last_login']),
      personalityType: json['personality_type'] ?? 'funny',
      memories: List<String>.from(json['memories'] ?? []),
      dailyInteractionCount: json['daily_interaction_count'] ?? 0,
      lastDailyLogin: json['last_daily_login'] != null
          ? DateTime.parse(json['last_daily_login'])
          : null,
    );
  }

  bool get isProActive {
    if (!isPro) return false;
    if (proExpiryDate == null) return true;
    return DateTime.now().isBefore(proExpiryDate!);
  }

  bool get canClaimDailyLogin {
    if (lastDailyLogin == null) return true;
    final now = DateTime.now();
    final lastLogin = lastDailyLogin!;
    return now.day != lastLogin.day || 
           now.month != lastLogin.month || 
           now.year != lastLogin.year;
  }
}

@HiveType(typeId: 1)
class UserPreferences {
  @HiveField(0)
  final bool isDarkMode;
  
  @HiveField(1)
  final bool voiceEnabled;
  
  @HiveField(2)
  final bool notificationsEnabled;
  
  @HiveField(3)
  final double voiceVolume;
  
  @HiveField(4)
  final String voiceLanguage;
  
  @HiveField(5)
  final bool autoMoodDetection;
  
  @HiveField(6)
  final bool backgroundAudio;
  
  @HiveField(7)
  final bool hapticFeedback;
  
  @HiveField(8)
  final double arScale;

  UserPreferences({
    this.isDarkMode = false,
    this.voiceEnabled = true,
    this.notificationsEnabled = true,
    this.voiceVolume = 0.7,
    this.voiceLanguage = 'en-US',
    this.autoMoodDetection = true,
    this.backgroundAudio = true,
    this.hapticFeedback = true,
    this.arScale = 1.0,
  });

  UserPreferences copyWith({
    bool? isDarkMode,
    bool? voiceEnabled,
    bool? notificationsEnabled,
    double? voiceVolume,
    String? voiceLanguage,
    bool? autoMoodDetection,
    bool? backgroundAudio,
    bool? hapticFeedback,
    double? arScale,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      autoMoodDetection: autoMoodDetection ?? this.autoMoodDetection,
      backgroundAudio: backgroundAudio ?? this.backgroundAudio,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      arScale: arScale ?? this.arScale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_dark_mode': isDarkMode,
      'voice_enabled': voiceEnabled,
      'notifications_enabled': notificationsEnabled,
      'voice_volume': voiceVolume,
      'voice_language': voiceLanguage,
      'auto_mood_detection': autoMoodDetection,
      'background_audio': backgroundAudio,
      'haptic_feedback': hapticFeedback,
      'ar_scale': arScale,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['is_dark_mode'] ?? false,
      voiceEnabled: json['voice_enabled'] ?? true,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      voiceVolume: (json['voice_volume'] ?? 0.7).toDouble(),
      voiceLanguage: json['voice_language'] ?? 'en-US',
      autoMoodDetection: json['auto_mood_detection'] ?? true,
      backgroundAudio: json['background_audio'] ?? true,
      hapticFeedback: json['haptic_feedback'] ?? true,
      arScale: (json['ar_scale'] ?? 1.0).toDouble(),
    );
  }
}

@HiveType(typeId: 2)
class UserStats {
  @HiveField(0)
  final int totalInteractions;
  
  @HiveField(1)
  final int totalDays;
  
  @HiveField(2)
  final int longestStreak;
  
  @HiveField(3)
  final int currentStreak;
  
  @HiveField(4)
  final int totalCoinsEarned;
  
  @HiveField(5)
  final int totalCoinsSpent;
  
  @HiveField(6)
  final int pranksUsed;
  
  @HiveField(7)
  final int quizzesCompleted;
  
  @HiveField(8)
  final Duration totalTalkTime;
  
  @HiveField(9)
  final Map<String, int> moodUsage;

  UserStats({
    this.totalInteractions = 0,
    this.totalDays = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.pranksUsed = 0,
    this.quizzesCompleted = 0,
    this.totalTalkTime = Duration.zero,
    this.moodUsage = const {},
  });

  UserStats copyWith({
    int? totalInteractions,
    int? totalDays,
    int? longestStreak,
    int? currentStreak,
    int? totalCoinsEarned,
    int? totalCoinsSpent,
    int? pranksUsed,
    int? quizzesCompleted,
    Duration? totalTalkTime,
    Map<String, int>? moodUsage,
  }) {
    return UserStats(
      totalInteractions: totalInteractions ?? this.totalInteractions,
      totalDays: totalDays ?? this.totalDays,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalCoinsSpent: totalCoinsSpent ?? this.totalCoinsSpent,
      pranksUsed: pranksUsed ?? this.pranksUsed,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalTalkTime: totalTalkTime ?? this.totalTalkTime,
      moodUsage: moodUsage ?? this.moodUsage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_interactions': totalInteractions,
      'total_days': totalDays,
      'longest_streak': longestStreak,
      'current_streak': currentStreak,
      'total_coins_earned': totalCoinsEarned,
      'total_coins_spent': totalCoinsSpent,
      'pranks_used': pranksUsed,
      'quizzes_completed': quizzesCompleted,
      'total_talk_time': totalTalkTime.inSeconds,
      'mood_usage': moodUsage,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalInteractions: json['total_interactions'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalCoinsEarned: json['total_coins_earned'] ?? 0,
      totalCoinsSpent: json['total_coins_spent'] ?? 0,
      pranksUsed: json['pranks_used'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      totalTalkTime: Duration(seconds: json['total_talk_time'] ?? 0),
      moodUsage: Map<String, int>.from(json['mood_usage'] ?? {}),
    );
  }
}