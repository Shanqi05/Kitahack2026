import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GeminiService {
  // API Key from new setup
  final String apiKey = "AIzaSyD_uZ5GiImGwscC0Ow7PD7HqWTfpwn4-ks";
  
  // REST API endpoint - using models that definitely work
  final String baseUrl = "https://generativelanguage.googleapis.com/v1beta/models";
  
  // Try these models in order
  final List<String> modelsToTry = [
    'gemini-1.5-flash',
    'gemini-1.5-pro', 
    'gemini-pro',
    'gemini-2.0-flash',
  ];

  GeminiService();

  /// Sends a message to the Gemini API and returns the text response
  Future<String> sendMessage(String message) async {
    try {
      // Check if API Key is valid
      if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
        return "⚠️ Error: API Key is missing. Please check gemini_service.dart";
      }

      // Try each model until one works
      for (String model in modelsToTry) {
        final result = await _tryModel(model, message);
        if (result != null && !result.contains('Error')) {
          return result;
        }
      }
      
      return "⚠️ Unable to reach AI service. Please try again in a moment.";
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  /// Try to send message with a specific model
  Future<String?> _tryModel(String model, String message) async {
    try {
      final url = Uri.parse(
        "$baseUrl/$model:generateContent?key=$apiKey"
      );

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
      ).timeout(const Duration(seconds: 30));

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
        // Model not found, try next one
        return null;
      } else {
        return "Error (${response.statusCode})";
      }
    } catch (e) {
      // Connection error, try next model
      return null;
    }
    return null;
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

  /// Analyze uploaded resume and extract key information
  Future<String> analyzeResume(PlatformFile file) async {
    final prompt = """
The student has uploaded a resume/CV: "${file.name}"

Please analyze this student's resume and extract:
1. Key skills mentioned in the resume
2. Academic strengths
3. Extracurricular activities or achievements
4. Recommended fields of study based on their background
5. University program suggestions in Malaysia

Format the response clearly with sections.
""";
    return await sendMessage(prompt);
  }

  /// Extract resume skills and profile summary
  Future<String> extractResumeSkills(PlatformFile file, {
    required String qualification,
    required List<String> interests,
  }) async {
    final prompt = """
Student has uploaded resume: "${file.name}"
- Qualification: $qualification
- Interests: ${interests.join(', ')}

Extract and list:
1. Technical skills found in resume
2. Soft skills demonstrated
3. Relevant work experience or projects
4. How resume aligns with their interests: ${interests.join(', ')}
5. Top 3 course recommendations in Malaysia universities

Be specific and concise.
""";
    return await sendMessage(prompt);
  }
}