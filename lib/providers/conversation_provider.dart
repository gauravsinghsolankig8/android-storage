import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/mood_model.dart';
import '../models/user_model.dart';
import '../services/ai_service.dart';
import 'package:uuid/uuid.dart';

class ConversationProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final Uuid _uuid = const Uuid();
  
  List<ConversationModel> _conversations = [];
  ConversationModel? _currentConversation;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  ConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;

  // Initialize
  Future<void> initialize() async {
    try {
      // Load saved conversations from storage
      await _loadConversations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Start new conversation
  Future<void> startNewConversation({
    required String userId,
    required MoodModel mood,
    String? title,
  }) async {
    try {
      final conversation = ConversationModel(
        id: _uuid.v4(),
        userId: userId,
        mood: mood.id,
        outfit: 'default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        context: ConversationContext(
          recentTopics: [],
          userPreferences: {},
          activeMemories: [],
          currentActivity: 'chat',
          sessionData: {},
        ),
      );

      _currentConversation = conversation;
      _conversations.insert(0, conversation);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Send message - Updated signature to match chat screen
  Future<void> sendMessage({
    required String content,
    required MoodModel mood,
    required UserModel? user,
  }) async {
    if (user == null) return;

    if (_currentConversation == null) {
      await startNewConversation(userId: user.id, mood: mood);
    }

    try {
      _isTyping = true;
      notifyListeners();

      // Add user message
      final userMessage = MessageModel(
        id: _uuid.v4(),
        content: content,
        type: MessageType.text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        metadata: MessageMetadata(
          mood: mood.id,
          outfit: user.currentOutfit,
        ),
      );

      final updatedMessages = List<MessageModel>.from(_currentConversation!.messages);
      updatedMessages.add(userMessage);
      
      _currentConversation = _currentConversation!.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
      _updateConversationInList();
      notifyListeners();

      // Get AI response
      final response = await _aiService.generateResponse(
        message: content,
        mood: mood,
        conversationHistory: _currentConversation!.messages,
      );

      // Add AI response
      final aiMessage = MessageModel(
        id: _uuid.v4(),
        content: response,
        type: MessageType.text,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        metadata: MessageMetadata(
          mood: mood.id,
          outfit: user.currentOutfit,
        ),
      );

      final finalMessages = List<MessageModel>.from(_currentConversation!.messages);
      finalMessages.add(aiMessage);

      _currentConversation = _currentConversation!.copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
      );
      
      _updateConversationInList();
      _isTyping = false;
      _error = null;
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      _isTyping = false;
      notifyListeners();
    }
  }

  // Update conversation in list
  void _updateConversationInList() {
    if (_currentConversation != null) {
      final index = _conversations.indexWhere(
        (conv) => conv.id == _currentConversation!.id,
      );
      if (index != -1) {
        _conversations[index] = _currentConversation!;
      }
    }
  }

  // Load conversation
  void loadConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => _conversations.first,
    );
    _currentConversation = conversation;
    notifyListeners();
  }

  // Delete conversation
  void deleteConversation(String conversationId) {
    _conversations.removeWhere((conv) => conv.id == conversationId);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = _conversations.isNotEmpty ? _conversations.first : null;
    }
    notifyListeners();
  }

  // Clear all conversations
  void clearAllConversations() {
    _conversations.clear();
    _currentConversation = null;
    notifyListeners();
  }

  // Load conversations from storage (placeholder)
  Future<void> _loadConversations() async {
    // TODO: Implement actual storage loading
    // For now, just initialize empty
    _conversations = [];
    notifyListeners();
  }

  // Save conversations to storage (placeholder)
  Future<void> saveConversations() async {
    // TODO: Implement actual storage saving
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}