import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  late final GenerativeModel _model;

  GeminiService() {
    // Debug: API key check
    print('🔑 API Key loaded: ${_apiKey.isNotEmpty}');
    print(
      '🔑 API Key preview: ${_apiKey.isNotEmpty ? '${_apiKey.substring(0, 10)}...' : 'MISSING'}',
    );

    // ✅ FREE & STABLE Gemini model
    _model = GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: _apiKey,
    );

    print('📱 Using model: models/gemini-2.0-flash');
  }

  Future<String?> getCareerAdvice(String studentData) async {
    if (_apiKey.isEmpty) {
      return "❌ API Key missing.\n\nPlease add GEMINI_API_KEY to your .env file.";
    }

    final prompt = """
Context:
You are a professional Malaysian career counselor helping SECONDARY SCHOOL students choose suitable university courses.

Student Profile:
$studentData

Respond in this EXACT format:

**Career Paths:**
1. [Career 1]
2. [Career 2]
3. [Career 3]

**Recommended University Courses (Malaysia-focused):**
1. **[Course Name]** – [University] – [Short explanation]
2. **[Course Name]** – [University] – [Short explanation]
3. **[Course Name]** – [University] – [Short explanation]

**Why these choices fit the student:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

Tone:
Encouraging, practical, and easy to understand for teenagers.
""";

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ??
          "❌ AI returned no response. Please try again.";
    } catch (e) {
      final error = e.toString();
      print('❌ Gemini Error: $error');

      if (error.contains('401') || error.contains('API key')) {
        return "❌ Invalid API Key.\n\nGet a new key from:\nhttps://aistudio.google.com/app/apikey";
      }

      if (error.contains('not found')) {
        return "❌ Model not found.\n\nMake sure you are using:\nmodels/gemini-2.0-flash";
      }

      if (error.contains('403') || error.contains('permission')) {
        return "❌ Permission denied.\n\nUse a Google AI Studio API key (not Cloud Console).";
      }

      if (error.contains('rate')) {
        return "⏳ Rate limit exceeded. Please wait and try again.";
      }

      return "❌ Unexpected AI error:\n$error";
    }
  }
}
