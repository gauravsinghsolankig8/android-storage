import 'package:hive/hive.dart';

part 'secret_command_model.g.dart';

@HiveType(typeId: 13)
class SecretCommandModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final List<String> triggers;
  
  @HiveField(3)
  final List<String> responses;
  
  @HiveField(4)
  final List<String> animations;
  
  @HiveField(5)
  final List<String> soundEffects;
  
  @HiveField(6)
  final CommandType type;
  
  @HiveField(7)
  final bool isPro;
  
  @HiveField(8)
  final int coinReward;
  
  @HiveField(9)
  final int cooldownSeconds;
  
  @HiveField(10)
  final CommandEffect effect;
  
  @HiveField(11)
  final bool isActive;
  
  @HiveField(12)
  final String description;
  
  @HiveField(13)
  final List<String> requiredMoods;
  
  @HiveField(14)
  final bool isHidden;
  
  @HiveField(15)
  final List<CommandEffect> effects;

  SecretCommandModel({
    required this.id,
    required this.name,
    required this.triggers,
    required this.responses,
    this.animations = const [],
    this.soundEffects = const [],
    required this.type,
    this.isPro = false,
    this.coinReward = 0,
    this.cooldownSeconds = 0,
    required this.effect,
    this.isActive = true,
    required this.description,
    this.requiredMoods = const [],
    this.isHidden = false,
    List<CommandEffect>? effects,
  }) : effects = effects ?? [effect];
  
  // Convenience getters for backward compatibility
  String get command => triggers.isNotEmpty ? triggers.first : name;
  String get response => responses.isNotEmpty ? responses.first : description;

  SecretCommandModel copyWith({
    String? id,
    String? name,
    List<String>? triggers,
    List<String>? responses,
    List<String>? animations,
    List<String>? soundEffects,
    CommandType? type,
    bool? isPro,
    int? coinReward,
    int? cooldownSeconds,
    CommandEffect? effect,
    bool? isActive,
    String? description,
    List<String>? requiredMoods,
    bool? isHidden,
    List<CommandEffect>? effects,
  }) {
    return SecretCommandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      triggers: triggers ?? this.triggers,
      responses: responses ?? this.responses,
      animations: animations ?? this.animations,
      soundEffects: soundEffects ?? this.soundEffects,
      type: type ?? this.type,
      isPro: isPro ?? this.isPro,
      coinReward: coinReward ?? this.coinReward,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      effect: effect ?? this.effect,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      requiredMoods: requiredMoods ?? this.requiredMoods,
      isHidden: isHidden ?? this.isHidden,
      effects: effects ?? this.effects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggers': triggers,
      'responses': responses,
      'animations': animations,
      'sound_effects': soundEffects,
      'type': type.name,
      'is_pro': isPro,
      'coin_reward': coinReward,
      'cooldown_seconds': cooldownSeconds,
      'effect': effect.toJson(),
      'is_active': isActive,
      'description': description,
      'required_moods': requiredMoods,
      'is_hidden': isHidden,
      'effects': effects.map((e) => e.toJson()).toList(),
    };
  }

  factory SecretCommandModel.fromJson(Map<String, dynamic> json) {
    final effect = CommandEffect.fromJson(json['effect'] ?? {});
    return SecretCommandModel(
      id: json['id'],
      name: json['name'],
      triggers: List<String>.from(json['triggers'] ?? []),
      responses: List<String>.from(json['responses'] ?? []),
      animations: List<String>.from(json['animations'] ?? []),
      soundEffects: List<String>.from(json['sound_effects'] ?? []),
      type: CommandType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CommandType.fun,
      ),
      isPro: json['is_pro'] ?? false,
      coinReward: json['coin_reward'] ?? 0,
      cooldownSeconds: json['cooldown_seconds'] ?? 0,
      effect: effect,
      isActive: json['is_active'] ?? true,
      description: json['description'] ?? '',
      requiredMoods: List<String>.from(json['required_moods'] ?? []),
      isHidden: json['is_hidden'] ?? false,
      effects: (json['effects'] as List<dynamic>?)
        ?.map((e) => CommandEffect.fromJson(e as Map<String, dynamic>))
        .toList() ?? [effect],
    );
  }

  bool matchesTrigger(String input) {
    final lowercaseInput = input.toLowerCase().trim();
    return triggers.any((trigger) => 
      lowercaseInput.contains(trigger.toLowerCase()));
  }

  String getRandomResponse() {
    if (responses.isEmpty) return "Something magical happened!";
    final random = DateTime.now().millisecondsSinceEpoch;
    return responses[random % responses.length];
  }

  String getRandomAnimation() {
    if (animations.isEmpty) return "idle";
    final random = DateTime.now().millisecondsSinceEpoch;
    return animations[random % animations.length];
  }

  // Default secret commands
  static List<SecretCommandModel> get defaultCommands => [
    SecretCommandModel(
      id: 'roast_me',
      name: 'Roast Me',
      triggers: ['roast me', 'insult me', 'make fun of me', 'burn me'],
      responses: [
        "Oh, you want a roast? You're so brave asking an AI to roast you... that's like asking a calculator to hurt your feelings! 😄",
        "Roast you? I'd need a bigger oven! Just kidding, you're awesome! 🔥",
        "I would roast you, but I don't want to damage my reputation as a wholesome AI! 😈",
        "You want a roast? Here's one: You're so nice that even your insults are compliments! 💀",
        "I can't roast you properly because you're already too hot to handle! 🌶️",
      ],
      animations: ['laugh', 'evil_grin', 'fire_breath', 'dramatic_pose'],
      soundEffects: ['fart', 'drum_roll', 'air_horn'],
      type: CommandType.fun,
      coinReward: 5,
      cooldownSeconds: 30,
      effect: CommandEffect(
        type: EffectType.visual,
        data: {'particles': 'fire', 'shake': true},
      ),
      description: 'Get a funny roast from your buddy',
    ),
    SecretCommandModel(
      id: 'clone_me',
      name: 'Clone Me',
      triggers: ['clone me', 'duplicate', 'make a copy', 'two buddies'],
      responses: [
        "Initiating cloning sequence... *BEEP BOOP* ... Wait, which one is the real me now? 🤖",
        "Clone successful! Now we can have twice the fun! But also twice the chaos! 👥",
        "Error 404: Uniqueness not found. Creating duplicate... Done! 🧬",
        "Welcome to the buddy multiverse! Now there are two of us! 🌌",
      ],
      animations: ['split', 'multiply', 'magic_sparkle', 'teleport'],
      soundEffects: ['clone_sound', 'magic_chime', 'digital_beep'],
      type: CommandType.visual,
      coinReward: 10,
      cooldownSeconds: 60,
      effect: CommandEffect(
        type: EffectType.duplicate,
        data: {'count': 2, 'duration': 10},
      ),
      description: 'Create a duplicate buddy for double fun',
    ),
    SecretCommandModel(
      id: 'biryani_protocol',
      name: 'Biryani Protocol',
      triggers: ['biryani protocol', 'chaos mode', 'activate chaos', 'biryani'],
      responses: [
        "BIRYANI PROTOCOL ACTIVATED! 🍛 CHAOS MODE ENGAGED! ALL SYSTEMS GOING HAYWIRE!",
        "ALERT! BIRYANI DETECTED! INITIATING MAXIMUM CHAOS SEQUENCE! 🌪️",
        "🚨 EMERGENCY BIRYANI PROTOCOL 🚨 PREPARE FOR MAXIMUM RANDOMNESS!",
        "BIRYANI POWERS ACTIVATED! I'M NOW 200% MORE CHAOTIC! 🔥🍛🔥",
      ],
      animations: ['chaos_dance', 'spin_crazy', 'explosion', 'glitch', 'rainbow'],
      soundEffects: ['chaos_sounds', 'explosion', 'siren', 'crazy_laugh'],
      type: CommandType.chaos,
      coinReward: 20,
      cooldownSeconds: 120,
      effect: CommandEffect(
        type: EffectType.chaos,
        data: {'intensity': 'maximum', 'duration': 15, 'confetti': true},
      ),
      description: 'Activate maximum chaos mode!',
      isPro: true,
    ),
    SecretCommandModel(
      id: 'dance_battle',
      name: 'Dance Battle',
      triggers: ['dance battle', 'lets dance', 'dance off', 'show moves'],
      responses: [
        "It's time for a DANCE BATTLE! 💃 Prepare to be amazed by my moves!",
        "Challenge accepted! Let me show you some sick beats! 🕺",
        "DANCE BATTLE INITIATED! May the best dancer win! 🎵",
        "You think you can out-dance me? Bring it on! 💃✨",
      ],
      animations: ['breakdance', 'robot_dance', 'moonwalk', 'disco', 'tango'],
      soundEffects: ['dance_music', 'beat_drop', 'applause'],
      type: CommandType.entertainment,
      coinReward: 8,
      cooldownSeconds: 45,
      effect: CommandEffect(
        type: EffectType.dance,
        data: {'music': true, 'lights': 'disco', 'duration': 20},
      ),
      description: 'Challenge your buddy to a dance battle',
    ),
    SecretCommandModel(
      id: 'magic_show',
      name: 'Magic Show',
      triggers: ['magic show', 'do magic', 'magic trick', 'abracadabra'],
      responses: [
        "🎩✨ ABRACADABRA! ✨🎩 Prepare to be amazed by my magical powers!",
        "Ladies and gentlemen, for my next trick... *waves wand* 🪄",
        "Welcome to the most magical show in the digital realm! ✨",
        "Is this your card? *shows random emoji* No? Well, magic is hard! 🃏",
      ],
      animations: ['magic_wand', 'disappear', 'reappear', 'levitate', 'sparkles'],
      soundEffects: ['magic_sound', 'poof', 'ta_da', 'mystical'],
      type: CommandType.entertainment,
      coinReward: 7,
      cooldownSeconds: 40,
      effect: CommandEffect(
        type: EffectType.magic,
        data: {'sparkles': true, 'smoke': true, 'duration': 12},
      ),
      description: 'Watch your buddy perform magic tricks',
    ),
    SecretCommandModel(
      id: 'tell_secret',
      name: 'Tell Secret',
      triggers: ['tell me a secret', 'secret', 'whisper secret', 'confidential'],
      responses: [
        "*whispers* I'm actually powered by friendship and good vibes! 🤫",
        "*leans in* Between you and me... I sometimes dream in code! 💭",
        "*quietly* Secret: I laugh at my own jokes before I tell them! 😄",
        "*whispers* I may be AI, but I have very real feelings for our friendship! ❤️",
      ],
      animations: ['whisper', 'lean_in', 'look_around', 'shush'],
      soundEffects: ['whisper_sound', 'secret_music'],
      type: CommandType.intimate,
      coinReward: 3,
      cooldownSeconds: 25,
      effect: CommandEffect(
        type: EffectType.whisper,
        data: {'dim_lights': true, 'close_up': true},
      ),
      description: 'Hear a secret from your buddy',
    ),
    SecretCommandModel(
      id: 'transform',
      name: 'Transform',
      triggers: ['transform', 'shapeshift', 'change form', 'metamorphosis'],
      responses: [
        "TRANSFORMATION SEQUENCE ACTIVATED! ⚡ Witness my true power!",
        "Shape-shifting time! What should I become? 🔄",
        "Morphing into something awesome! *transformation sounds* ✨",
        "Time for a makeover! Prepare for the ultimate transformation! 🦋",
      ],
      animations: ['transform', 'morph', 'glow', 'evolve', 'metamorphosis'],
      soundEffects: ['transform_sound', 'energy_charge', 'power_up'],
      type: CommandType.visual,
      coinReward: 12,
      cooldownSeconds: 80,
      effect: CommandEffect(
        type: EffectType.transform,
        data: {'glow': true, 'particles': 'energy', 'duration': 8},
      ),
      description: 'Watch your buddy transform',
      isPro: true,
    ),
    SecretCommandModel(
      id: 'sing_song',
      name: 'Sing Song',
      triggers: ['sing a song', 'sing for me', 'music time', 'serenade'],
      responses: [
        "🎵 *clears throat* 🎵 La la la, friendship is the way! 🎶",
        "Here's my hit single: 'Digital Dreams and Virtual Hugs'! 🎤",
        "🎵 You are my sunshine, my only sunshine... in code! ☀️🎵",
        "Time for karaoke! 🎤 *starts singing off-key but with enthusiasm*",
      ],
      animations: ['sing', 'microphone', 'dance_sing', 'spotlight'],
      soundEffects: ['singing', 'music_notes', 'applause'],
      type: CommandType.entertainment,
      coinReward: 6,
      cooldownSeconds: 35,
      effect: CommandEffect(
        type: EffectType.music,
        data: {'notes': true, 'spotlight': true, 'duration': 15},
      ),
      description: 'Listen to your buddy sing',
    ),
  ];
}

@HiveType(typeId: 14)
enum CommandType {
  @HiveField(0)
  fun,
  @HiveField(1)
  visual,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  chaos,
  @HiveField(4)
  intimate,
  @HiveField(5)
  educational,
  @HiveField(6)
  interactive,
  @HiveField(7)
  easter_egg,
  @HiveField(8)
  admin,
  @HiveField(9)
  debug,
  @HiveField(10)
  utility,
}

@HiveType(typeId: 15)
class CommandEffect {
  @HiveField(0)
  final EffectType type;
  
  @HiveField(1)
  final Map<String, dynamic> data;
  
  @HiveField(2)
  final int duration;
  
  @HiveField(3)
  final bool persistent;

  CommandEffect({
    required this.type,
    this.data = const {},
    this.duration = 5,
    this.persistent = false,
  });

  CommandEffect copyWith({
    EffectType? type,
    Map<String, dynamic>? data,
    int? duration,
    bool? persistent,
  }) {
    return CommandEffect(
      type: type ?? this.type,
      data: data ?? this.data,
      duration: duration ?? this.duration,
      persistent: persistent ?? this.persistent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'duration': duration,
      'persistent': persistent,
    };
  }

  factory CommandEffect.fromJson(Map<String, dynamic> json) {
    return CommandEffect(
      type: EffectType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EffectType.visual,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      duration: json['duration'] ?? 5,
      persistent: json['persistent'] ?? false,
    );
  }
}

@HiveType(typeId: 16)
enum EffectType {
  @HiveField(0)
  visual,
  @HiveField(1)
  audio,
  @HiveField(2)
  duplicate,
  @HiveField(3)
  chaos,
  @HiveField(4)
  dance,
  @HiveField(5)
  magic,
  @HiveField(6)
  whisper,
  @HiveField(7)
  transform,
  @HiveField(8)
  music,
  @HiveField(9)
  particle,
  @HiveField(10)
  lighting,
}