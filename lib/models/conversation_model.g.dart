// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final int typeId = 7;

  @override
  ConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      messages: (fields[2] as List).cast<MessageModel>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      mood: fields[5] as String,
      outfit: fields[6] as String,
      context: fields[7] as ConversationContext,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.outfit)
      ..writeByte(7)
      ..write(obj.context)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 8;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      content: fields[1] as String,
      type: fields[2] as MessageType,
      sender: fields[3] as MessageSender,
      timestamp: fields[4] as DateTime,
      audioPath: fields[5] as String?,
      duration: fields[6] as Duration?,
      animations: (fields[7] as List).cast<String>(),
      metadata: fields[8] as MessageMetadata,
      isMemory: fields[9] as bool,
      replyToId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.audioPath)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.animations)
      ..writeByte(8)
      ..write(obj.metadata)
      ..writeByte(9)
      ..write(obj.isMemory)
      ..writeByte(10)
      ..write(obj.replyToId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageMetadataAdapter extends TypeAdapter<MessageMetadata> {
  @override
  final int typeId = 11;

  @override
  MessageMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageMetadata(
      mood: fields[0] as String,
      outfit: fields[1] as String,
      confidence: fields[2] as double,
      tags: (fields[3] as List).cast<String>(),
      extra: (fields[4] as Map).cast<String, dynamic>(),
      voiceStyle: fields[5] as String?,
      isSpecialCommand: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageMetadata obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.mood)
      ..writeByte(1)
      ..write(obj.outfit)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.extra)
      ..writeByte(5)
      ..write(obj.voiceStyle)
      ..writeByte(6)
      ..write(obj.isSpecialCommand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationContextAdapter extends TypeAdapter<ConversationContext> {
  @override
  final int typeId = 12;

  @override
  ConversationContext read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationContext(
      recentTopics: (fields[0] as List).cast<String>(),
      userPreferences: (fields[1] as Map).cast<String, String>(),
      activeMemories: (fields[2] as List).cast<String>(),
      currentActivity: fields[3] as String,
      sessionData: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversationContext obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.recentTopics)
      ..writeByte(1)
      ..write(obj.userPreferences)
      ..writeByte(2)
      ..write(obj.activeMemories)
      ..writeByte(3)
      ..write(obj.currentActivity)
      ..writeByte(4)
      ..write(obj.sessionData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 9;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.voice;
      case 2:
        return MessageType.system;
      case 3:
        return MessageType.command;
      case 4:
        return MessageType.memory;
      case 5:
        return MessageType.emotion;
      case 6:
        return MessageType.action;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.voice:
        writer.writeByte(1);
        break;
      case MessageType.system:
        writer.writeByte(2);
        break;
      case MessageType.command:
        writer.writeByte(3);
        break;
      case MessageType.memory:
        writer.writeByte(4);
        break;
      case MessageType.emotion:
        writer.writeByte(5);
        break;
      case MessageType.action:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageSenderAdapter extends TypeAdapter<MessageSender> {
  @override
  final int typeId = 10;

  @override
  MessageSender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSender.user;
      case 1:
        return MessageSender.ai;
      case 2:
        return MessageSender.system;
      default:
        return MessageSender.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSender obj) {
    switch (obj) {
      case MessageSender.user:
        writer.writeByte(0);
        break;
      case MessageSender.ai:
        writer.writeByte(1);
        break;
      case MessageSender.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
