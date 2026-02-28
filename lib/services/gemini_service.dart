import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GeminiService {
  final String apiKey = "AIzaSyD_uZ5GiImGwscC0Ow7PD7HqWTfpwn4-ks";
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models";

  final List<String> modelsToTry = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'gemini-2.0-flash',
  ];

  GeminiService();

  Future<String> sendMessage(String message, {PlatformFile? file}) async {
    try {
      if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
        return "⚠️ Error: API Key is missing. Please check gemini_service.dart";
      }

      // Step 1: Try sending with the file
      for (String model in modelsToTry) {
        final result = await _tryModel(model, message, file: file);
        if (result != null && !result.contains('Error')) {
          // 🔥 NEW: Explicitly tell the user the file was successfully read!
          if (file != null) {
            return "✅ **[Success: Resume file read & analyzed by AI]**\n\n$result";
          }
          return result; // Normal text-only response (if no file was uploaded)
        }
      }

      // Step 2: INTELLIGENT FALLBACK
      // 如果带文件发送失败，剥离文件，单纯发送文字！
      if (file != null) {
        print("File upload failed, retrying with text only (Fallback)...");
        for (String model in modelsToTry) {
          final result = await _tryModel(model, message, file: null);
          if (result != null && !result.contains('Error')) {
            // 🔥 NEW: Tell the user it fell back to Profile-only mode
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
      final url = Uri.parse("$baseUrl/$model:generateContent?key=$apiKey");

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
}