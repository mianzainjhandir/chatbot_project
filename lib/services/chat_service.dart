import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart';
import '../models/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> getChatResponse(List<ChatMessage> history) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo', // You can change this to gpt-4 if you have access
          'messages': history.map((m) => m.toOpenAIFormat()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']['message'] ?? 'Failed to get response');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
