import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GeminiService {
  // API Key hardcoded for stability as requested
  final String apiKey = "AIzaSyAUNyxBWI_jpxWswyvzaR5fgQVQ81w6fL4";
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  GeminiService();

  /// Sends a message to the Gemini API and returns the text response
  Future<String> sendMessage(String message) async {
    try {
      // Check if API Key is valid
      if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
        return "⚠️ Error: API Key is missing. Please check gemini_service.dart";
      }

      // Construct the full URL with the API key
      final url = Uri.parse("$baseUrl?key=$apiKey");

      // Send a POST request to Google's servers
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      // Check if the request was successful (HTTP 200 OK)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse the JSON response to extract the text
        // Structure: candidates[0] -> content -> parts[0] -> text
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {

          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return "AI returned an empty response.";
      } else {
        // Log error if status code is not 200
        return "Server Error (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      // Catch network or parsing errors
      return "Connection Error: $e";
    }
  }

  /// Get career recommendations based on student profile
  Future<String> getCareerRecommendations({
    required String qualification,
    required bool upu,
    required Map<String, String> grades,
    required List<String> interests,
    double? budget,
    PlatformFile? resumeFile,
  }) async {
    // Format grades into a readable string
    String gradesSummary = grades.entries.map((e) => "${e.key}: ${e.value}").join(", ");

    // Format resume info
    String resumeInfo = resumeFile != null ? "Resume: ${resumeFile.name}" : "No resume";

    // Construct the prompt for the AI
    final prompt = """
You are a career counselor. Profile:
- Qualification: $qualification
- Mode: ${upu ? 'UPU' : 'Private'}
- Grades: $gradesSummary
- Interests: ${interests.join(', ')}
- Budget: ${budget ?? 'No limit'}
- $resumeInfo

Suggest 3 courses and 2 universities in Malaysia. Keep it short.
""";

    return await sendMessage(prompt);
  }

  /// Analyze uploaded resume
  Future<String> analyzeResume(PlatformFile file) async {
    return await sendMessage("Analyze resume: ${file.name} for university advice.");
  }
}