import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  bool get isConfigured => apiKey.isNotEmpty;

  GeminiService() {
    if (!isConfigured) {
      print(
        "Warning: GEMINI_API_KEY is not set. Chat functionality will use mock responses.",
      );
    }
  }

  /// Chat with Gemini AI
  Future<String> sendMessage(String message) async {
    try {
      // If API key is not configured, return a mock response
      if (!isConfigured) {
        return _getMockResponse(message);
      }

      final payload = {
        "contents": [
          {
            "parts": [
              {"text": message},
            ],
          },
        ],
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": 500},
      };

      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            "No response from AI";
        return text;
      } else {
        throw Exception("Failed to get response: ${response.body}");
      }
    } catch (e) {
      return "Sorry, I encountered an error: $e";
    }
  }

  /// Generate mock response when API key is not configured
  String _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('course') || lowerMessage.contains('program')) {
      return "Great question! Based on your interests, I recommend exploring programs in Software Engineering, Data Science, and Web Development. These fields have excellent job prospects and align well with modern career paths.";
    } else if (lowerMessage.contains('career') ||
        lowerMessage.contains('job')) {
      return "The tech industry offers many exciting career paths! You could consider roles like Software Developer, Data Analyst, UX Designer, or Product Manager. Each has unique challenges and rewards.";
    } else if (lowerMessage.contains('university') ||
        lowerMessage.contains('uni')) {
      return "When choosing a university, consider factors like: program reputation, internship opportunities, campus culture, and post-graduation employment rates. I recommend researching programs that align with your interests.";
    } else {
      return "That's an interesting question! While I'm currently in demo mode, I'm here to help guide you through your career exploration. Feel free to ask about specific fields, universities, or career paths.";
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
    String gradesSummary = grades.entries
        .map((e) => "${e.key}: ${e.value}")
        .join(", ");
    String resumeInfo = resumeFile != null
        ? "Resume uploaded: ${resumeFile.name}"
        : "No resume";

    final prompt =
        """
You are a career counselor AI. Based on the following student profile, provide 3 top course recommendations for Malaysian universities.

Student Profile:
- Qualification: $qualification
- Application Mode: ${upu ? 'UPU' : 'Direct/Private'}
- Grades: $gradesSummary
- Interests: ${interests.join(', ')}
${budget != null ? '- Budget: RM$budget per year' : '- No budget limit'}
- $resumeInfo

Please provide:
1. Top 3 course recommendations
2. Recommended universities
3. Why these courses match the student's profile
4. Admission requirements if applicable

Format the response clearly with course names, universities, and brief explanations.
""";

    return await sendMessage(prompt);
  }

  /// Analyze uploaded resume
  Future<String> analyzeResume(PlatformFile file) async {
    try {
      // For now, return a placeholder since we can't directly read file content in Flutter web
      final prompt =
          """
Please analyze this resume information: ${file.name}
This is a student's resume who is seeking career guidance for Malaysian university courses.
Provide a brief summary of:
1. Key skills identified
2. Relevant experience
3. Career interests that might suit them
4. Recommendations for further development
""";

      return await sendMessage(prompt);
    } catch (e) {
      return "Failed to analyze resume: $e";
    }
  }
}
