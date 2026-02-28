import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../core/constants/secrets.dart'; // Ensure this points to your secrets file!

class GeminiService {
  // ✅ SECURELY PULLING KEY FROM SECRETS.DART
  static const String _apiKey = Secrets.geminiApiKey;
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models";

  final List<String> modelsToTry = [
    'gemini-2.5-flash',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-2.0-flash',
  ];

  GeminiService();

  Future<String> sendMessage(String message, {PlatformFile? file}) async {
    try {
      if (_apiKey.isEmpty || _apiKey == "YOUR_ACTUAL_API_KEY_HERE") {
        return "⚠️ Error: API Key is missing. Please check secrets.dart";
      }

      // Step 1: Try sending with the file
      for (String model in modelsToTry) {
        final result = await _tryModel(model, message, file: file);
        if (result != null && !result.contains('Error')) {
          // Explicitly tell the user the file was successfully read
          if (file != null) {
            return "✅ **[Success: Resume file read & analyzed by AI]**\n\n$result";
          }
          return result; // Normal text-only response
        }
      }

      // Step 2: INTELLIGENT FALLBACK (If file upload fails, retry with text only)
      if (file != null) {
        print("File upload failed, retrying with text only (Fallback)...");
        for (String model in modelsToTry) {
          final result = await _tryModel(model, message, file: null);
          if (result != null && !result.contains('Error')) {
            return "⚠️ **[Notice: Resume file unreadable (format/size issue). Analysis is based on your Grades & Interests instead]**\n\n$result";
          }
        }
      }

      return "⚠️ Unable to reach AI service. Please try again in a moment.";
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  Future<String?> _tryModel(String model, String message, {PlatformFile? file}) async {
    try {
      final url = Uri.parse("$baseUrl/$model:generateContent?key=$_apiKey");

      List<Map<String, dynamic>> parts = [
        {"text": message}
      ];

      if (file != null && file.bytes != null) {
        String base64Data = base64Encode(file.bytes!);
        String mimeType = 'application/pdf';

        final ext = file.extension?.toLowerCase();
        if (ext == 'png') mimeType = 'image/png';
        else if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';

        parts.add({
          "inlineData": {
            "mimeType": mimeType,
            "data": base64Data
          }
        });
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": parts}]
        }),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text ?? "Empty response";
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return "Error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // =========================================================================
  // Resume Analysis
  // =========================================================================
  Future<String> getResumeFeedback(PlatformFile? file, Map<String, String> grades, List<String> interests) async {
    String fileNameInfo = file != null ? "The student uploaded a resume named '${file.name}'." : "No resume file was attached.";

    final prompt = """
You are an expert university admission officer and career counselor. 
$fileNameInfo
Here is the student's background profile:
- Academic Grades: ${grades.entries.map((e) => "${e.key}: ${e.value}").join(", ")}
- Career Interests: ${interests.join(", ")}

Based on this academic profile (and the resume if readable), provide a direct, concise analysis structured EXACTLY like this (use the emojis):

🌟 **Profile & Resume Strengths**
(List 2 strong points about their grades or how their interests align with their background)

📈 **Areas for Improvement**
(List 2 specific things they should add to their resume or skills they should learn based on their interests)

💡 **Admission Advice**
(Give 1 short paragraph of highly practical advice on how they can stand out in university applications)

Be encouraging but highly practical. Do not include introductory or concluding pleasantries.
""";

    return await sendMessage(prompt, file: file);
  }

  Future<String> getCareerRecommendations({
    required String qualification, required bool upu, required Map<String, String> grades, required List<String> interests, double? budget, PlatformFile? resumeFile,
  }) async {
    String gradesSummary = grades.entries.map((e) => "${e.key}: ${e.value}").join(", ");
    String resumeInfo = resumeFile != null ? "Resume: ${resumeFile.name}" : "No resume";
    final prompt = "You are a career counselor. Profile:\n- Qualification: $qualification\n- Mode: ${upu ? 'UPU' : 'Private'}\n- Grades: $gradesSummary\n- Interests: ${interests.join(', ')}\n- Budget: ${budget ?? 'No limit'}\n- $resumeInfo\nSuggest 3 courses and 2 universities in Malaysia. Keep it short.";
    return await sendMessage(prompt);
  }

  Future<String> analyzeResume(PlatformFile file) async {
    return await sendMessage("Analyze this resume and extract key skills, strengths, and recommended study fields.", file: file);
  }

  Future<Map<String, dynamic>> scanDocument(String imagePathOrBase64) async {
    if (imagePathOrBase64 == "dummy_path") {
      await Future.delayed(const Duration(seconds: 2));
      return {
        "subjects": [
          {"name": "Bahasa Melayu", "grade": "A+"},
          {"name": "English", "grade": "A"},
          {"name": "Mathematics", "grade": "A-"},
        ],
      };
    }

    try {
      final url = Uri.parse('$baseUrl/gemini-2.5-flash:generateContent?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Analyze this SPM result slip. Extract ALL subjects and grades. Return JSON object with key 'subjects' which is a list. Rules: 1. Map Malay names to English/Standard names: 'Matematik'->'Mathematics', 'Fizik'->'Physics', 'Kimia'->'Chemistry', 'Biologi'->'Biology', 'Matematik Tambahan'->'Additional Mathematics', 'Prinsip Perakaunan'->'Principles of Accounting', 'Pendidikan Seni Visual'->'Visual Arts', 'Pendidikan Al-Quran dan Al-Sunnah'->'Al-Quran and Al-Sunnah Education', 'Pendidikan Syariah Islamiah'->'Syariah Islamiah Education', 'Tasawwur Islam'->'Islamic Worldview'. 2. Keep these names AS IS: 'Bahasa Melayu', 'Bahasa Inggeris', 'Sejarah', 'Pendidikan Islam', 'Pendidikan Moral', 'Bahasa Arab', 'Bahasa Cina', 'Bahasa Tamil'. 3. If 'English' is found, map to 'Bahasa Inggeris'. 4. Grade format: A+, A, A-, B+, B, C+, C, D, E, G. Example: {\"subjects\": [{\"name\": \"Bahasa Melayu\", \"grade\": \"A+\"}]}",
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
        if (candidates == null || candidates.isEmpty) throw Exception('No candidates.');
        final text = candidates.first['content']?['parts']?.first['text'] as String?;
        if (text == null) throw Exception('No text in response.');

        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          return jsonDecode(text.substring(jsonStart, jsonEnd + 1));
        }
        throw Exception('Failed to parse JSON.');
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Gemini scan error: $e');
    }
  }
}