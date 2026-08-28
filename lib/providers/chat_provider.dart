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
      String errorMessage = "Something went wrong. Please try again.";
      
      if (e.toString().contains("insufficient_quota")) {
        errorMessage = "⚠️ OpenAI Quota Exceeded. Please check your billing/plan at platform.openai.com.";
      } else if (e.toString().contains("invalid_api_key")) {
        errorMessage = "🔑 Invalid API Key. Please check your api_key.dart file.";
      } else if (e.toString().contains("Connection error")) {
        errorMessage = "🌐 Connection error. Please check your internet.";
      }

      _messages.add(ChatMessage(
        content: errorMessage,
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
