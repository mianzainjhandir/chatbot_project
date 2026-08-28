import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(content: text, role: MessageRole.user);
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final responseContent = await _chatService.getChatResponse(_messages);
      
      final assistantMessage = ChatMessage(
        content: responseContent,
        role: MessageRole.assistant,
      );
      _messages.add(assistantMessage);
    } catch (e) {
      // Add error message as assistant for UI feedback
      _messages.add(ChatMessage(
        content: "Error: ${e.toString()}",
        role: MessageRole.assistant,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
