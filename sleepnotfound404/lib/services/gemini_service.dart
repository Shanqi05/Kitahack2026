import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String?> getCareerAdvice(String studentData) async {
    if (_apiKey.isEmpty) return "Error: API Key missing in .env";

    final prompt = [
      Content.text("""
        Context: You are a professional Malaysian Career Counselor.
        User Input: $studentData
        
        Task: 
        1. Predict 3 future career paths.
        2. Recommend 3 specific university courses in Malaysia (mentioning USM, UM, etc.).
        3. Provide a brief "Why" for each.
        
        Tone: Encouraging and professional.
      """)
    ];

    try {
      final response = await _model.generateContent(prompt);
      return response.text;
    } catch (e) {
      return "AI Analysis failed: ${e.toString()}";
    }
  }
}