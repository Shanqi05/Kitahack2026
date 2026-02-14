import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/course_repository.dart';
import '../data/admission_engine.dart';
import '../models/student_profile.dart';
// Use local JSON service for insights
import '../data/career_insight_service.dart';
import 'admission_chat_screen.dart';

class ResultScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final double? budget;
  final PlatformFile? resumeFile;

  const ResultScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.budget,
    this.resumeFile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<RecommendedProgram>> _getRecommendations;
  // Future for local JSON insights
  late Future<List<InsightModel>> _getInsights;

  @override
  void initState() {
    super.initState();
    _getRecommendations = _loadRecommendations();
    // Load local insights based on interests
    _getInsights = CareerInsightService().getMatchedInsights(widget.interests);
  }

  Future<List<RecommendedProgram>> _loadRecommendations() async {
    try {
      final repository = CourseRepository();
      await repository.loadData();

      final student = StudentProfile(
        qualification: widget.qualification,
        isUpu: widget.upu,
        interest: widget.interests,
        spmGrades: widget.grades,
        budget: widget.budget,
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
              const Text(
                'Your Future Path',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your profile and interests',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              // --- 1. Enhanced Profile Summary ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Summary',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7)
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Qualification', widget.qualification),
                    _buildInfoRow('Mode', widget.upu ? 'UPU (Public)' : 'Private'),
                    // Show the selected budget
                    _buildInfoRow('Budget', 'RM ${widget.budget?.toStringAsFixed(0)} / year'),

                    const Divider(height: 24),
                    const Text("Grades:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    // Display all entered grades
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.grades.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            "${entry.key}: ${entry.value}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. Smart Insights (Based on Budget & Grades) ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph, color: Color(0xFF673AB7)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _generateSmartInsight(), // Generates advice based on logic
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4527A0)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. Personal Insights (Cards from JSON) ---
              FutureBuilder<List<InsightModel>>(
                future: _getInsights,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final insights = snapshot.data ?? [];
                  if (insights.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: insights.map((insight) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration().copyWith(
                        border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Color(0xFF673AB7)),
                              const SizedBox(width: 10),
                              Text(
                                '${insight.title} Insights',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF673AB7)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                              insight.insight,
                              style: const TextStyle(fontSize: 14, height: 1.5)
                          ),
                          const SizedBox(height: 12),
                          const Text(
                              "Recommended Careers:",
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: insight.careers.map((c) => Chip(
                              label: Text(c, style: const TextStyle(fontSize: 12)),
                              backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        insight.advice,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[800])
                                    )
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )).toList(),
                  );
                },
              ),

              // --- 4. Matched Courses ---
              FutureBuilder<List<RecommendedProgram>>(
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
                        const Text(
                          'Matched Courses',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF673AB7)
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (recommendations.isEmpty)
                          const Text(
                              'No direct matches found. Try adjusting criteria.',
                              style: TextStyle(color: Colors.grey)
                          )
                        else
                          ...recommendations.take(10).map((course) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildCourseCard(course),
                              )
                          ),
                      ],
                    ),
                  );
                },
              ),

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
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Consult AI Advisor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: 16),

              // Back Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  // Generates advice based on budget and grades
  String _generateSmartInsight() {
    double budget = widget.budget ?? 0;
    bool highBudget = budget > 40000;
    bool lowBudget = budget < 15000;

    // Check for good grades (A or A+)
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    bool goodGrades = aCount >= 3;

    if (goodGrades && lowBudget) {
      return "With your excellent grades (${aCount} As), you are a strong candidate for scholarships.";
    } else if (highBudget) {
      return "Your budget of RM ${budget.toStringAsFixed(0)} allows you to explore premium private university options.";
    } else if (widget.upu) {
      return "Focusing on UPU is a great strategy for cost-effective education with your current profile.";
    } else {
      return "Consider applying for PTPTN loans or financial aid to support your preferred course.";
    }
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(RecommendedProgram course) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              course.courseName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF673AB7))
          ),
          const SizedBox(height: 4),
          Text(
              "${course.universityName} • ${course.location}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700])
          ),
          const SizedBox(height: 4),
          Text(
              "RM ${course.annualFee.toStringAsFixed(0)} / year",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}