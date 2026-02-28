import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/course_repository.dart';
import '../data/admission_engine.dart';
import '../models/student_profile.dart';
import '../data/career_insight_service.dart';
import 'admission_chat_screen.dart';
import '../../dashboard/screens/main_dashboard_shell.dart';

class ResultScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final double? budget;
  final PlatformFile? resumeFile;
  final String? stream;
  final String? diplomaField;

  const ResultScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.budget,
    this.resumeFile,
    this.stream,
    this.diplomaField,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<RecommendedProgram>> _getRecommendations;
  late Future<List<InsightModel>> _getInsights;

  @override
  void initState() {
    super.initState();
    _getRecommendations = _loadRecommendations();
    _getInsights = CareerInsightService().getMatchedInsights(widget.interests);
  }

  Future<List<RecommendedProgram>> _loadRecommendations() async {
    try {
      final repository = CourseRepository();
      await repository.loadData();

      // Extract CGPA and co-curricular mark from grades map
      double? cgpa = widget.grades['CGPA'] != null
          ? double.tryParse(widget.grades['CGPA']!)
          : null;
      double coCurricularMark = widget.grades['CocurricularMark'] != null
          ? double.tryParse(widget.grades['CocurricularMark']!) ?? 0.0
          : 0.0;

      // Extract subject marks for different qualification types
      List<int> spmCompulsory = [];
      List<int> spmElective = [];
      List<int> spmAdditional = [];

      if (widget.qualification == 'SPM' && widget.upu) {
        // For SPM UPU, parse subject marks
        widget.grades.forEach((subject, grade) {
          if (subject != 'CGPA' && subject != 'CocurricularMark') {
            // Grade to numeric conversion for SPM calculation
            final gradeToPoints = {
              'A+': 18,
              'A': 17,
              'A-': 16,
              'B+': 15,
              'B': 14,
              'C+': 13,
              'C': 12,
              'D': 11,
              'E': 10,
              'G': 0,
            };
            final points = gradeToPoints[grade] ?? 0;
            // Assuming 4 compulsory, 2 elective, rest additional
            if (spmCompulsory.length < 4) {
              spmCompulsory.add(points);
            } else if (spmElective.length < 2) {
              spmElective.add(points);
            } else {
              spmAdditional.add(points);
            }
          }
        });
      }

      final student = StudentProfile(
        qualification: widget.qualification,
        isUpu: widget.upu,
        interest: widget.interests,
        spmGrades: widget.grades,
        budget: widget.budget,
        stream: widget.stream,
        diplomaField: widget.diplomaField,
        cgpa: cgpa,
        coCurricularMark: coCurricularMark,
        spmCompulsoryMarks: spmCompulsory.isNotEmpty ? spmCompulsory : null,
        spmElectiveMarks: spmElective.isNotEmpty ? spmElective : null,
        spmAdditionalMarks: spmAdditional.isNotEmpty ? spmAdditional : null,
      );

      final engine = AdmissionEngine(repository: repository);
      return engine.getRecommendations(student);
    } catch (e) {
      debugPrint("Error loading courses: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Recommendations"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Your Future Path',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your profile and interests',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              // Grade Suitability Alert
              _buildGradeValidationAlert(),

              const SizedBox(height: 24),

              // --- 1. User Strength ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF673AB7),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Your Strength',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF673AB7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generateUserStrengthSummary(),
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 2. Scholarship Opportunity ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: Color(0xFF673AB7),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Scholarship Opportunity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF673AB7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generateScholarshipComment(),
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. Career Insight ---
              FutureBuilder<List<InsightModel>>(
                future: _getInsights,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final insights = snapshot.data ?? [];
                  if (insights.isEmpty) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              color: Color(0xFF673AB7),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Career Insights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF673AB7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...insights.map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF673AB7),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  insight.insight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: insight.careers
                                      .take(3)
                                      .map(
                                        (c) => Chip(
                                          label: Text(
                                            c,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFF673AB7,
                                          ).withOpacity(0.15),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Matched Courses from JSON ---
              _buildMatchedCoursesSection(),

              const SizedBox(height: 30),

              // Consult AI Advisor Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdmissionChatScreen(
                        qualification: widget.qualification,
                        upu: widget.upu,
                        grades: widget.grades,
                        interests: widget.interests,
                        budget: widget.budget,
                        resumeFile: widget.resumeFile,
                        stream: widget.stream,
                        diplomaField: widget.diplomaField,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Consult AI Advisor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: 16),

              // Back to Home Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainDashboardShell()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  // Generate User Strength Summary
  String _generateUserStrengthSummary() {
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    int goodGrades = widget.grades.values
        .where((g) => g == 'A' || g == 'A+' || g == 'B+')
        .length;

    String summary = "";
    if (aCount >= 4) {
      summary =
          "Excellent academic performance! Your ${aCount} A grades demonstrate strong capability and commitment. ";
    } else if (aCount >= 2) {
      summary =
          "Good academic foundation with ${aCount} A grades. You're well-positioned for your interests. ";
    } else if (goodGrades >= 3) {
      summary =
          "Solid grades showing consistent performance. You have potential in your chosen fields. ";
    } else {
      summary =
          "Your grades show ability. Focus on strengthening specific subjects related to your interests. ";
    }

    summary += widget.interests.isNotEmpty
        ? "Your interests in ${widget.interests.join(', ')} align well for further specialization."
        : "";

    return summary;
  }

  // Generate Scholarship Comment
  String _generateScholarshipComment() {
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    double budget = widget.budget ?? 0;

    if (aCount >= 5) {
      return "Congratulations! With your excellent grades, you're eligible for top-tier scholarships like JPA, Petronas, and Yayasan Khazanah. These cover full tuition + living allowance.";
    } else if (aCount >= 3 && budget < 30000) {
      return "Your good grades qualify you for merit-based scholarships. Explore government and corporate scholarships to ease your financial burden.";
    } else if (budget > 50000) {
      return "With your higher budget, focus on quality institutions without heavy scholarship dependency. You can also explore partial scholarships.";
    } else if (budget < 20000) {
      return "Consider PTPTN loans, need-based scholarships, or cost-effective UPU options to support your education.";
    } else {
      return "You have various scholarship options available. Research institution-specific scholarships for your chosen programs.";
    }
  }

  // Build Grade Validation Alert
  Widget _buildGradeValidationAlert() {
    List<String> alerts = _getGradeValidationAlerts();

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Grade Compatibility Alert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(alert, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get Grade Validation Alerts
  List<String> _getGradeValidationAlerts() {
    List<String> alerts = [];
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    int cCount = widget.grades.values
        .where((g) => g == 'C' || g == 'C+' || g == 'C-')
        .length;

    // Check Math/Science grades for engineering/IT
    if (widget.interests.contains('Engineering') ||
        widget.interests.contains('IT')) {
      final mathGrade = widget.grades['Math'];
      final scienceGrade =
          widget.grades['Physics'] ?? widget.grades['Chemistry'];
      if (mathGrade == 'C' ||
          mathGrade == 'C+' ||
          scienceGrade == 'C' ||
          scienceGrade == 'C+') {
        alerts.add(
          "⚠ Consider retaking Math/Science for strong Engineering/IT programs, or explore foundational courses.",
        );
      }
    }

    // Check overall grades
    if (cCount >= 2) {
      alerts.add(
        "⚠ Your C grades may limit options for competitive programs. Consider retaking or adjusting your path.",
      );
    } else if (aCount == 0 &&
        widget.grades.values.where((g) => g.startsWith('B')).isEmpty) {
      alerts.add(
        "⚠ Consider strengthening your grades before applying to highly selective programs.",
      );
    }

    return alerts;
  }

  // Build Matched Courses Section from JSON
  Widget _buildMatchedCoursesSection() {
    return FutureBuilder<List<RecommendedProgram>>(
      future: _getRecommendations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recommendations = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, color: Color(0xFF673AB7), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Matched Courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF673AB7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendations.isEmpty)
                const Text(
                  'No matches found. Chat with AI Advisor for personalized guidance.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...recommendations
                    .take(8)
                    .map(
                      (course) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSimpleCourseCard(course),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Simplified Course Card
  Widget _buildSimpleCourseCard(RecommendedProgram course) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.courseName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${course.universityName} • ${course.location}",
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            "RM ${course.annualFee.toStringAsFixed(0)} / year",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF673AB7).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
