import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'outfit_model.g.dart';

@HiveType(typeId: 5)
class OutfitModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String displayName;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String thumbnailUrl;
  
  @HiveField(5)
  final String modelUrl;
  
  @HiveField(6)
  final String category;
  
  @HiveField(7)
  final int coinPrice;
  
  @HiveField(8)
  final double? realPrice;
  
  @HiveField(9)
  final String currency;
  
  @HiveField(10)
  final bool isPro;
  
  @HiveField(11)
  final bool isLimited;
  
  @HiveField(12)
  final DateTime? availableUntil;
  
  @HiveField(13)
  final List<String> tags;
  
  @HiveField(14)
  final String rarity;
  
  @HiveField(15)
  final OutfitAssets assets;
  
  @HiveField(16)
  final bool isActive;
  
  @HiveField(17)
  final String? unlockCondition;
  
  @HiveField(18)
  final List<String> compatibleMoods;
  
  @HiveField(19)
  final String colorHex;

  OutfitModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.thumbnailUrl,
    required this.modelUrl,
    required this.category,
    this.coinPrice = 0,
    this.realPrice,
    this.currency = 'INR',
    this.isPro = false,
    this.isLimited = false,
    this.availableUntil,
    this.tags = const [],
    this.rarity = 'common',
    required this.assets,
    this.isActive = true,
    this.unlockCondition,
    this.compatibleMoods = const [],
    this.colorHex = '#6B73FF',
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  
  int get unlockCost => coinPrice;

  OutfitModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? thumbnailUrl,
    String? modelUrl,
    String? category,
    int? coinPrice,
    double? realPrice,
    String? currency,
    bool? isPro,
    bool? isLimited,
    DateTime? availableUntil,
    List<String>? tags,
    String? rarity,
    OutfitAssets? assets,
    bool? isActive,
    String? unlockCondition,
    List<String>? compatibleMoods,
    String? colorHex,
  }) {
    return OutfitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      modelUrl: modelUrl ?? this.modelUrl,
      category: category ?? this.category,
      coinPrice: coinPrice ?? this.coinPrice,
      realPrice: realPrice ?? this.realPrice,
      currency: currency ?? this.currency,
      isPro: isPro ?? this.isPro,
      isLimited: isLimited ?? this.isLimited,
      availableUntil: availableUntil ?? this.availableUntil,
      tags: tags ?? this.tags,
      rarity: rarity ?? this.rarity,
      assets: assets ?? this.assets,
      isActive: isActive ?? this.isActive,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      compatibleMoods: compatibleMoods ?? this.compatibleMoods,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'model_url': modelUrl,
      'category': category,
      'coin_price': coinPrice,
      'real_price': realPrice,
      'currency': currency,
      'is_pro': isPro,
      'is_limited': isLimited,
      'available_until': availableUntil?.toIso8601String(),
      'tags': tags,
      'rarity': rarity,
      'assets': assets.toJson(),
      'is_active': isActive,
      'unlock_condition': unlockCondition,
      'compatible_moods': compatibleMoods,
      'color_hex': colorHex,
    };
  }

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      modelUrl: json['model_url'],
      category: json['category'],
      coinPrice: json['coin_price'] ?? 0,
      realPrice: json['real_price']?.toDouble(),
      currency: json['currency'] ?? 'INR',
      isPro: json['is_pro'] ?? false,
      isLimited: json['is_limited'] ?? false,
      availableUntil: json['available_until'] != null
          ? DateTime.parse(json['available_until'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      rarity: json['rarity'] ?? 'common',
      assets: OutfitAssets.fromJson(json['assets'] ?? {}),
      isActive: json['is_active'] ?? true,
      unlockCondition: json['unlock_condition'],
      compatibleMoods: List<String>.from(json['compatible_moods'] ?? []),
      colorHex: json['color_hex'] ?? '#6B73FF',
    );
  }

  bool get isAvailable {
    if (!isActive) return false;
    if (!isLimited) return true;
    if (availableUntil == null) return true;
    return DateTime.now().isBefore(availableUntil!);
  }

  bool get isFree => coinPrice == 0 && realPrice == null;

  String get rarityColor {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return '#FFD700';
      case 'epic':
        return '#9370DB';
      case 'rare':
        return '#4169E1';
      case 'uncommon':
        return '#32CD32';
      default:
        return '#808080';
    }
  }

  // Default outfits
  static List<OutfitModel> get defaultOutfits => [
    OutfitModel(
      id: 'default',
      name: 'default',
      displayName: 'Default Buddy',
      description: 'The classic EchoBuddy look',
      thumbnailUrl: 'assets/outfits/default/thumbnail.png',
      modelUrl: 'assets/3d_models/default_buddy.glb',
      category: 'basic',
      rarity: 'common',
      colorHex: '#6B73FF',
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/default_buddy.glb',
        textureFiles: ['assets/3d_models/textures/default_texture.png'],
        animationFiles: ['assets/3d_models/animations/default_idle.fbx'],
      ),
      compatibleMoods: ['happy', 'sleepy', 'joker'],
    ),
    OutfitModel(
      id: 'casual_cool',
      name: 'casual_cool',
      displayName: 'Casual Cool',
      description: 'Relaxed and stylish everyday look',
      thumbnailUrl: 'assets/outfits/casual_cool/thumbnail.png',
      modelUrl: 'assets/3d_models/casual_cool.glb',
      category: 'casual',
      coinPrice: 25,
      rarity: 'common',
      colorHex: '#32CD32',
      tags: ['casual', 'cool', 'everyday'],
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/casual_cool.glb',
        textureFiles: ['assets/3d_models/textures/casual_texture.png'],
        animationFiles: ['assets/3d_models/animations/casual_idle.fbx'],
      ),
      compatibleMoods: ['happy', 'joker'],
    ),
    OutfitModel(
      id: 'formal_suit',
      name: 'formal_suit',
      displayName: 'Formal Suit',
      description: 'Professional and sophisticated attire',
      thumbnailUrl: 'assets/outfits/formal_suit/thumbnail.png',
      modelUrl: 'assets/3d_models/formal_suit.glb',
      category: 'formal',
      coinPrice: 50,
      rarity: 'uncommon',
      colorHex: '#2F4F4F',
      tags: ['formal', 'professional', 'suit'],
      isPro: true,
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/formal_suit.glb',
        textureFiles: ['assets/3d_models/textures/suit_texture.png'],
        animationFiles: ['assets/3d_models/animations/formal_idle.fbx'],
      ),
      compatibleMoods: ['romantic', 'villain'],
    ),
    OutfitModel(
      id: 'party_outfit',
      name: 'party_outfit',
      displayName: 'Party Outfit',
      description: 'Fun and vibrant party clothes',
      thumbnailUrl: 'assets/outfits/party_outfit/thumbnail.png',
      modelUrl: 'assets/3d_models/party_outfit.glb',
      category: 'party',
      coinPrice: 40,
      rarity: 'rare',
      colorHex: '#FF69B4',
      tags: ['party', 'fun', 'colorful'],
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/party_outfit.glb',
        textureFiles: ['assets/3d_models/textures/party_texture.png'],
        animationFiles: ['assets/3d_models/animations/party_idle.fbx'],
      ),
      compatibleMoods: ['happy', 'joker'],
    ),
    OutfitModel(
      id: 'villain_cape',
      name: 'villain_cape',
      displayName: 'Villain Cape',
      description: 'Dark and mysterious villain outfit',
      thumbnailUrl: 'assets/outfits/villain_cape/thumbnail.png',
      modelUrl: 'assets/3d_models/villain_cape.glb',
      category: 'themed',
      coinPrice: 75,
      realPrice: 49.0,
      rarity: 'epic',
      colorHex: '#8B0000',
      tags: ['villain', 'dark', 'cape'],
      isPro: true,
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/villain_cape.glb',
        textureFiles: ['assets/3d_models/textures/villain_texture.png'],
        animationFiles: ['assets/3d_models/animations/villain_idle.fbx'],
      ),
      compatibleMoods: ['villain'],
    ),
    OutfitModel(
      id: 'romantic_dress',
      name: 'romantic_dress',
      displayName: 'Romantic Dress',
      description: 'Elegant and romantic evening wear',
      thumbnailUrl: 'assets/outfits/romantic_dress/thumbnail.png',
      modelUrl: 'assets/3d_models/romantic_dress.glb',
      category: 'romantic',
      coinPrice: 60,
      rarity: 'rare',
      colorHex: '#FF1493',
      tags: ['romantic', 'elegant', 'dress'],
      isPro: true,
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/romantic_dress.glb',
        textureFiles: ['assets/3d_models/textures/romantic_texture.png'],
        animationFiles: ['assets/3d_models/animations/romantic_idle.fbx'],
      ),
      compatibleMoods: ['romantic'],
    ),
    OutfitModel(
      id: 'pajamas',
      name: 'pajamas',
      displayName: 'Cozy Pajamas',
      description: 'Comfortable sleepwear for relaxation',
      thumbnailUrl: 'assets/outfits/pajamas/thumbnail.png',
      modelUrl: 'assets/3d_models/pajamas.glb',
      category: 'sleepwear',
      coinPrice: 30,
      rarity: 'common',
      colorHex: '#9370DB',
      tags: ['sleepwear', 'cozy', 'comfortable'],
      assets: OutfitAssets(
        glbFile: 'assets/3d_models/pajamas.glb',
        textureFiles: ['assets/3d_models/textures/pajama_texture.png'],
        animationFiles: ['assets/3d_models/animations/sleepy_idle.fbx'],
      ),
      compatibleMoods: ['sleepy'],
    ),
  ];
}

@HiveType(typeId: 6)
class OutfitAssets {
  @HiveField(0)
  final String glbFile;
  
  @HiveField(1)
  final List<String> textureFiles;
  
  @HiveField(2)
  final List<String> animationFiles;
  
  @HiveField(3)
  final Map<String, String> materialMappings;
  
  @HiveField(4)
  final String? normalMapFile;
  
  @HiveField(5)
  final String? roughnessMapFile;
  
  @HiveField(6)
  final String? modelPath;
  
  @HiveField(7)
  final List<String> texturePaths;
  
  @HiveField(8)
  final List<String> animationPaths;
  
  @HiveField(9)
  final String? thumbnailPath;

  OutfitAssets({
    required this.glbFile,
    this.textureFiles = const [],
    this.animationFiles = const [],
    this.materialMappings = const {},
    this.normalMapFile,
    this.roughnessMapFile,
    String? modelPath,
    List<String>? texturePaths,
    List<String>? animationPaths,
    this.thumbnailPath,
  }) : modelPath = modelPath ?? glbFile,
       texturePaths = texturePaths ?? textureFiles,
       animationPaths = animationPaths ?? animationFiles;

  OutfitAssets copyWith({
    String? glbFile,
    List<String>? textureFiles,
    List<String>? animationFiles,
    Map<String, String>? materialMappings,
    String? normalMapFile,
    String? roughnessMapFile,
    String? modelPath,
    List<String>? texturePaths,
    List<String>? animationPaths,
    String? thumbnailPath,
  }) {
    return OutfitAssets(
      glbFile: glbFile ?? this.glbFile,
      textureFiles: textureFiles ?? this.textureFiles,
      animationFiles: animationFiles ?? this.animationFiles,
      materialMappings: materialMappings ?? this.materialMappings,
      normalMapFile: normalMapFile ?? this.normalMapFile,
      roughnessMapFile: roughnessMapFile ?? this.roughnessMapFile,
      modelPath: modelPath ?? this.modelPath,
      texturePaths: texturePaths ?? this.texturePaths,
      animationPaths: animationPaths ?? this.animationPaths,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glb_file': glbFile,
      'texture_files': textureFiles,
      'animation_files': animationFiles,
      'material_mappings': materialMappings,
      'normal_map_file': normalMapFile,
      'roughness_map_file': roughnessMapFile,
      'model_path': modelPath,
      'texture_paths': texturePaths,
      'animation_paths': animationPaths,
      'thumbnail_path': thumbnailPath,
    };
  }

  factory OutfitAssets.fromJson(Map<String, dynamic> json) {
    return OutfitAssets(
      glbFile: json['glb_file'] ?? '',
      textureFiles: List<String>.from(json['texture_files'] ?? []),
      animationFiles: List<String>.from(json['animation_files'] ?? []),
      materialMappings: Map<String, String>.from(json['material_mappings'] ?? {}),
      normalMapFile: json['normal_map_file'],
      roughnessMapFile: json['roughness_map_file'],
      modelPath: json['model_path'],
      texturePaths: List<String>.from(json['texture_paths'] ?? json['texture_files'] ?? []),
      animationPaths: List<String>.from(json['animation_paths'] ?? json['animation_files'] ?? []),
      thumbnailPath: json['thumbnail_path'],
    );
  }
}