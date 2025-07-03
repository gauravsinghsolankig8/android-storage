// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secret_command_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecretCommandModelAdapter extends TypeAdapter<SecretCommandModel> {
  @override
  final int typeId = 13;

  @override
  SecretCommandModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SecretCommandModel(
      id: fields[0] as String,
      name: fields[1] as String,
      triggers: (fields[2] as List).cast<String>(),
      responses: (fields[3] as List).cast<String>(),
      animations: (fields[4] as List).cast<String>(),
      soundEffects: (fields[5] as List).cast<String>(),
      type: fields[6] as CommandType,
      isPro: fields[7] as bool,
      coinReward: fields[8] as int,
      cooldownSeconds: fields[9] as int,
      effect: fields[10] as CommandEffect,
      isActive: fields[11] as bool,
      description: fields[12] as String,
      requiredMoods: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SecretCommandModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.triggers)
      ..writeByte(3)
      ..write(obj.responses)
      ..writeByte(4)
      ..write(obj.animations)
      ..writeByte(5)
      ..write(obj.soundEffects)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.isPro)
      ..writeByte(8)
      ..write(obj.coinReward)
      ..writeByte(9)
      ..write(obj.cooldownSeconds)
      ..writeByte(10)
      ..write(obj.effect)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.requiredMoods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecretCommandModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommandEffectAdapter extends TypeAdapter<CommandEffect> {
  @override
  final int typeId = 15;

  @override
  CommandEffect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommandEffect(
      type: fields[0] as EffectType,
      data: (fields[1] as Map).cast<String, dynamic>(),
      duration: fields[2] as int,
      persistent: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CommandEffect obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.persistent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommandTypeAdapter extends TypeAdapter<CommandType> {
  @override
  final int typeId = 14;

  @override
  CommandType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CommandType.fun;
      case 1:
        return CommandType.visual;
      case 2:
        return CommandType.entertainment;
      case 3:
        return CommandType.chaos;
      case 4:
        return CommandType.intimate;
      case 5:
        return CommandType.educational;
      case 6:
        return CommandType.interactive;
      default:
        return CommandType.fun;
    }
  }

  @override
  void write(BinaryWriter writer, CommandType obj) {
    switch (obj) {
      case CommandType.fun:
        writer.writeByte(0);
        break;
      case CommandType.visual:
        writer.writeByte(1);
        break;
      case CommandType.entertainment:
        writer.writeByte(2);
        break;
      case CommandType.chaos:
        writer.writeByte(3);
        break;
      case CommandType.intimate:
        writer.writeByte(4);
        break;
      case CommandType.educational:
        writer.writeByte(5);
        break;
      case CommandType.interactive:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EffectTypeAdapter extends TypeAdapter<EffectType> {
  @override
  final int typeId = 16;

  @override
  EffectType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EffectType.visual;
      case 1:
        return EffectType.audio;
      case 2:
        return EffectType.duplicate;
      case 3:
        return EffectType.chaos;
      case 4:
        return EffectType.dance;
      case 5:
        return EffectType.magic;
      case 6:
        return EffectType.whisper;
      case 7:
        return EffectType.transform;
      case 8:
        return EffectType.music;
      case 9:
        return EffectType.particle;
      case 10:
        return EffectType.lighting;
      default:
        return EffectType.visual;
    }
  }

  @override
  void write(BinaryWriter writer, EffectType obj) {
    switch (obj) {
      case EffectType.visual:
        writer.writeByte(0);
        break;
      case EffectType.audio:
        writer.writeByte(1);
        break;
      case EffectType.duplicate:
        writer.writeByte(2);
        break;
      case EffectType.chaos:
        writer.writeByte(3);
        break;
      case EffectType.dance:
        writer.writeByte(4);
        break;
      case EffectType.magic:
        writer.writeByte(5);
        break;
      case EffectType.whisper:
        writer.writeByte(6);
        break;
      case EffectType.transform:
        writer.writeByte(7);
        break;
      case EffectType.music:
        writer.writeByte(8);
        break;
      case EffectType.particle:
        writer.writeByte(9);
        break;
      case EffectType.lighting:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
