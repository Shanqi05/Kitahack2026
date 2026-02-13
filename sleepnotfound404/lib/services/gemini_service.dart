import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class GeminiService {
  late final String apiKey;
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  bool get isConfigured => apiKey.isNotEmpty;

  GeminiService() {
    try {
      apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    } catch (e) {
      apiKey = "";
      print("Warning: Could not access GEMINI_API_KEY: $e");
    }

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

    // Check for specific keywords and respond accordingly
    if (lowerMessage.contains('recommend') ||
        lowerMessage.contains('suggest') ||
        lowerMessage.contains('best') ||
        lowerMessage.contains('which course')) {
      return "Based on your interests and profile, I recommend exploring these fields:\n\n"
          "1. **Software Engineering** - High demand, excellent career prospects\n"
          "2. **Data Science** - Growing field with competitive salaries\n"
          "3. **Business Analytics** - Combines tech with business insights\n\n"
          "Would you like more details about any of these?";
    } else if (lowerMessage.contains('course') ||
        lowerMessage.contains('program') ||
        lowerMessage.contains('degree')) {
      return "Great question! Here are some popular course options:\n\n"
          "• Bachelor of Software Engineering\n"
          "• Bachelor of Data Science\n"
          "• Bachelor of Information Technology\n"
          "• Diploma in Computer Science\n"
          "• Foundation in Engineering\n\n"
          "Which of these interests you the most?";
    } else if (lowerMessage.contains('university') ||
        lowerMessage.contains('uni') ||
        lowerMessage.contains('which university')) {
      return "Popular universities in Malaysia offering technology programs:\n\n"
          "• University of Malaya (UM)\n"
          "• Universiti Teknologi Malaysia (UTM)\n"
          "• Universiti Kebangsaan Malaysia (UKM)\n"
          "• Universiti Putra Malaysia (UPM)\n"
          "• Universiti Sains Malaysia (USM)\n\n"
          "I can help you find the best fit based on your preferences!";
    } else if (lowerMessage.contains('career') ||
        lowerMessage.contains('job') ||
        lowerMessage.contains('work')) {
      return "Career paths in technology are diverse and rewarding:\n\n"
          "• Software Developer - Creating applications and systems\n"
          "• Data Analyst - Turning data into insights\n"
          "• Systems Administrator - Managing IT infrastructure\n"
          "• UX/UI Designer - Creating user-friendly interfaces\n"
          "• Product Manager - Leading product development\n\n"
          "What type of work appeals to you most?";
    } else if (lowerMessage.contains('salary') ||
        lowerMessage.contains('pay') ||
        lowerMessage.contains('income')) {
      return "Tech careers typically offer competitive salaries:\n\n"
          "• Entry-level: RM2,500 - RM3,500/month\n"
          "• Mid-level (3-5 yrs): RM4,000 - RM6,000/month\n"
          "• Senior level: RM7,000+/month\n\n"
          "Salaries vary based on company, location, and specialization. "
          "Would you like guidance on specific roles?";
    } else if (lowerMessage.contains('requirement') ||
        lowerMessage.contains('qualify') ||
        lowerMessage.contains('entry')) {
      return "Entry requirements depend on your qualification and choice:\n\n"
          "• SPM: Foundation or Diploma programs\n"
          "• A-Levels/STPM: Direct entry to Bachelor's\n"
          "• Matrikulasi: Direct entry to Bachelor's\n"
          "• Diploma: Entry to Bachelor's (2-year top-up)\n\n"
          "Based on your profile, I can suggest the best path for you!";
    } else {
      return "That's a great question! I'm here to help you explore career and course options. "
          "You can ask me about:\n\n"
          "• Course recommendations\n"
          "• University options\n"
          "• Career paths\n"
          "• Admission requirements\n"
          "• Salary expectations\n\n"
          "What would you like to know more about?";
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
