import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/secrets.dart';

class GeminiService {
  // Key is loaded from secrets.dart (gitignored)
  static const String _apiKey = Secrets.geminiApiKey;
  // Using gemini-2.5-flash (multimodal, matches available quota in current project)
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<Map<String, dynamic>> scanDocument(String imagePathOrBase64) async {
    // If no real image is passed (demo mode), return mock data immediately
    // or you can try to send your "dummy_path" to Gemini but it will likely fail or hallucinate.
    if (imagePathOrBase64 == "dummy_path") {
      // Artificial delay for realism
      await Future.delayed(const Duration(seconds: 2));
      return {
        "subjects": [
          {"name": "Bahasa Melayu", "grade": "A+"},
          {"name": "English", "grade": "A"},
          {"name": "Mathematics", "grade": "A-"},
          {"name": "Sejarah", "grade": "B+"},
          {"name": "Physics", "grade": "B"},
          {"name": "Chemistry", "grade": "C+"},
        ],
      };
    }

    // --- REAL IMPLEMENTATION ---
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Analyze this SPM result slip. Extract ALL subjects and grades. Return JSON object with key 'subjects' which is a list. Rules: 1. Map Malay names to English/Standard names: 'Matematik'->'Mathematics', 'Fizik'->'Physics', 'Kimia'->'Chemistry', 'Biologi'->'Biology', 'Matematik Tambahan'->'Additional Mathematics', 'Prinsip Perakaunan'->'Principles of Accounting', 'Pendidikan Seni Visual'->'Visual Arts', 'Pendidikan Al-Quran dan Al-Sunnah'->'Al-Quran and Al-Sunnah Education', 'Pendidikan Syariah Islamiah'->'Syariah Islamiah Education', 'Tasawwur Islam'->'Islamic Worldview'. 2. Keep these names AS IS: 'Bahasa Melayu', 'Bahasa Inggeris', 'Sejarah', 'Pendidikan Islam', 'Pendidikan Moral', 'Bahasa Arab', 'Bahasa Cina', 'Bahasa Tamil'. 3. If 'English' is found, map to 'Bahasa Inggeris'. 4. Grade format: A+, A, A-, B+, B, C+, C, D, E, G. Example: {\"subjects\": [{\"name\": \"Bahasa Melayu\", \"grade\": \"A+\"}]}",
                },
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": imagePathOrBase64,
                  },
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception(
            'Gemini returned no candidates. Body: ${response.body}',
          );
        }

        final parts = candidates.first['content']?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception(
            'Gemini returned empty parts. Body: ${response.body}',
          );
        }

        final text = parts.first['text'] as String?;
        if (text == null || text.isEmpty) {
          throw Exception('Gemini returned empty text. Body: ${response.body}');
        }

        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = text.substring(jsonStart, jsonEnd + 1);
          return jsonDecode(jsonStr);
        }

        throw Exception('Unable to parse Gemini response text: $text');
      }

      throw Exception('Gemini HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      // Bubble up detailed errors so UI can show them.
      throw Exception('Gemini scan error: $e');
    }
  }

  Future<String> chatWithGemini(String message) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are a helpful Malaysian Education Advisor assistant. Answer concisely.\n\nUser: $message",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Sorry, I am having trouble connecting to my brain right now. (Error ${response.statusCode})";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
