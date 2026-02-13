import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  GeminiService() {
    if (apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY is not set in .env");
    }
  }

  /// Chat with Gemini AI
  Future<String> sendMessage(String message) async {
    final uri = Uri.parse(
      "https://api.generativeai.google/v1beta2/models/text-bison-001:generateText",
    );

    final payload = {
      "prompt": message,
      "temperature": 0.5,
      "maxOutputTokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini usually returns text in candidates[0].content
      return data['candidates']?[0]?['content'] ?? "No response from AI";
    } else {
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  /// Analyze uploaded resume
  Future<String> analyzeResume(dynamic file) async {
    // Keep the previous analyzeResume implementation
    // ...
    return "Resume analysis placeholder";
  }
}
