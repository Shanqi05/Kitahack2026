import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/course_repository.dart';
import '../data/admission_engine.dart';
import '../models/student_profile.dart';
import 'admission_chat_screen.dart';
import '../../../services/gemini_service.dart';
import '../../home/presentation/home_screen.dart';
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
  Future<String>? _resumeFeedbackFuture;

  @override
  void initState() {
    super.initState();
    _getRecommendations = _loadRecommendations();

    // 🔥 即使没有上传文件，也可以触发 AI 背景分析（基于成绩和兴趣）
    _resumeFeedbackFuture = GeminiService().getResumeFeedback(
      widget.resumeFile,
      widget.grades,
      widget.interests,
    );
  }

  Future<List<RecommendedProgram>> _loadRecommendations() async {
    try {
      final repository = CourseRepository();
      await repository.loadData();

      double? cgpa = widget.grades['CGPA'] != null ? double.tryParse(widget.grades['CGPA']!) : null;
      double coCurricularMark = widget.grades['CocurricularMark'] != null ? double.tryParse(widget.grades['CocurricularMark']!) ?? 0.0 : 0.0;

      List<int> spmCompulsory = [];
      List<int> spmElective = [];
      List<int> spmAdditional = [];

      if (widget.qualification == 'SPM' && widget.upu) {
        widget.grades.forEach((subject, grade) {
          if (subject != 'CGPA' && subject != 'CocurricularMark' && subject != 'MUET') {
            final gradeToPoints = {
              'A+': 18, 'A': 17, 'A-': 16, 'B+': 15, 'B': 14,
              'C+': 13, 'C': 12, 'D': 11, 'E': 10, 'G': 0,
            };
            final points = gradeToPoints[grade] ?? 0;
            if (spmCompulsory.length < 4) spmCompulsory.add(points);
            else if (spmElective.length < 2) spmElective.add(points);
            else spmAdditional.add(points);
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your profile and interests',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              _buildGradeValidationAlert(),
              const SizedBox(height: 24),

              // --- 1. User Strength & Careers ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF673AB7), size: 24),
                        const SizedBox(width: 10),
                        Text('Strength & Recommended Careers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_getUserStrengthIntro(), style: const TextStyle(fontSize: 14, height: 1.5)),
                    const SizedBox(height: 16),
                    ..._getRecommendedCareers().map((career) => _buildCareerCard(career)).toList(),
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
                        const Icon(Icons.card_giftcard, color: Color(0xFF673AB7), size: 24),
                        const SizedBox(width: 10),
                        Text('Scholarship Matches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_getScholarshipIntro(), style: const TextStyle(fontSize: 14, height: 1.5)),
                    const SizedBox(height: 16),
                    ..._getRecommendedScholarships().map((scholarship) => _buildScholarshipCard(scholarship)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. Matched Courses ---
              _buildMatchedCoursesSection(),
              const SizedBox(height: 20),

              // --- 4. NEW: AI Resume & Profile Analysis ---
              _buildResumeAnalysisSection(),
              const SizedBox(height: 30),

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
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainDashboardShell()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[300]!)
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

  // ==========================================
  // AI Resume Analysis Builder (Updated)
  // ==========================================
  Widget _buildResumeAnalysisSection() {
    if (_resumeFeedbackFuture == null) return const SizedBox.shrink();

    return FutureBuilder<String>(
      future: _resumeFeedbackFuture,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF673AB7))
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.resumeFile != null
                        ? "AI is analyzing your resume and profile..."
                        : "AI is analyzing your profile...",
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }

        // 2. Error/Fallback State (Will show even if API fails)
        String aiText = snapshot.data ?? "⚠️ AI analysis is currently unavailable. Please check your connection.";

        // 3. Success State
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF673AB7).withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF673AB7).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner, color: Color(0xFF673AB7), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Profile & Resume Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Text(
                aiText,
                style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // EXISTING METHODS
  // ==========================================

  String _getUserStrengthIntro() {
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    if (aCount >= 4) return "Excellent academic performance! Your $aCount A grades demonstrate strong capability.";
    if (aCount >= 2) return "Good academic foundation with $aCount A grades. You're well-positioned.";
    return "Your grades show solid potential. Here are careers that match your interests.";
  }

  List<Map<String, dynamic>> _getRecommendedCareers() {
    List<Map<String, dynamic>> careers = [];
    if (widget.interests.any((i) => i.contains('IT') || i.contains('Computer') || i.contains('Technology'))) {
      careers.add({'title': 'Software Engineer', 'salary': 'RM 3,500 - RM 12,000', 'icon': Icons.computer});
      careers.add({'title': 'Data Analyst', 'salary': 'RM 3,500 - RM 8,500', 'icon': Icons.analytics});
    } else if (widget.interests.any((i) => i.contains('Engineering'))) {
      careers.add({'title': 'Mechanical Engineer', 'salary': 'RM 3,000 - RM 8,000', 'icon': Icons.engineering});
      careers.add({'title': 'Project Engineer', 'salary': 'RM 3,200 - RM 9,000', 'icon': Icons.architecture});
    } else if (widget.interests.any((i) => i.contains('Business') || i.contains('Finance'))) {
      careers.add({'title': 'Financial Analyst', 'salary': 'RM 3,200 - RM 10,000', 'icon': Icons.attach_money});
      careers.add({'title': 'Marketing Manager', 'salary': 'RM 3,500 - RM 8,500', 'icon': Icons.campaign});
    } else if (widget.interests.any((i) => i.contains('Health') || i.contains('Science'))) {
      careers.add({'title': 'Biomedical Scientist', 'salary': 'RM 3,000 - RM 7,000', 'icon': Icons.biotech});
      careers.add({'title': 'Healthcare Admin', 'salary': 'RM 3,000 - RM 6,800', 'icon': Icons.local_hospital});
    } else {
      careers.add({'title': 'Management Trainee', 'salary': 'RM 3,000 - RM 4,500', 'icon': Icons.business_center});
      careers.add({'title': 'Operations Executive', 'salary': 'RM 2,500 - RM 5,500', 'icon': Icons.trending_up});
    }
    return careers;
  }

  Widget _buildCareerCard(Map<String, dynamic> career) {
    return Card(
      elevation: 0,
      color: const Color(0xFF673AB7).withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF673AB7).withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Icon(career['icon'], color: const Color(0xFF673AB7), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(career['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text("Expected Salary: ${career['salary']}", style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScholarshipIntro() {
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    if (aCount >= 5) return "Based on your outstanding grades, you are highly competitive for these premium scholarships:";
    if (aCount >= 3) return "Your solid academic performance opens doors to these corporate and university scholarships:";
    return "Here are the best financial aids and scholarships suited for your profile and budget:";
  }

  List<Map<String, String>> _getRecommendedScholarships() {
    List<Map<String, String>> scholarships = [];
    int aCount = widget.grades.values.where((g) => g.startsWith('A')).length;
    double budget = widget.budget ?? 0;

    double muet = 0.0;
    if (widget.grades['MUET'] != null) {
      muet = double.tryParse(widget.grades['MUET']!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    if (aCount >= 7) {
      scholarships.add({'name': 'JPA Scholarship (PIDN)', 'provider': 'Jabatan Perkhidmatan Awam', 'amount': 'Full Coverage + Allowance', 'link': 'https://esilav2.jpa.gov.my/'});
      scholarships.add({'name': 'Yayasan Khazanah', 'provider': 'Khazanah Nasional', 'amount': 'Full Scholarship', 'link': 'https://www.yayasankhazanah.com.my/'});
    } else if (aCount >= 4) {
      scholarships.add({'name': 'Shell Malaysia Scholarship', 'provider': 'Shell Malaysia', 'amount': 'Full Tuition', 'link': 'https://www.shell.com.my/'});
      scholarships.add({'name': 'Maybank Group Scholarship', 'provider': 'Maybank Foundation', 'amount': 'RM 10,000 / year', 'link': 'https://www.maybankfoundation.com/'});
    } else if (budget < 30000) {
      scholarships.add({'name': 'PTPTN Loan (WPP)', 'provider': 'Government', 'amount': 'Up to RM 1,500 Advance', 'link': 'https://www.ptptn.gov.my/'});
    }

    if (muet >= 4.0 && !scholarships.any((s) => s['name']!.contains('Star'))) {
      scholarships.add({'name': 'The Star Education Fund', 'provider': 'The Star Media Group', 'amount': 'Full / Partial Tuition', 'link': 'https://www.thestar.com.my/edufund'});
    }

    if (scholarships.isEmpty) {
      scholarships.add({'name': 'PTPTN Education Loan', 'provider': 'Government', 'amount': 'Variable based on course', 'link': 'https://www.ptptn.gov.my/'});
    }

    return scholarships;
  }

  Widget _buildScholarshipCard(Map<String, String> scholarship) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.school, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scholarship['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(scholarship['provider']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 6),
                      Expanded(child: Text(scholarship['amount']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[700]), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Applying for ${scholarship['name']}...")));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF673AB7),
                    side: const BorderSide(color: Color(0xFF673AB7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text("Apply Now", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeValidationAlert() {
    List<String> alerts = _getGradeValidationAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();

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
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Compatibility Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline, size: 16, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(alert, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getGradeValidationAlerts() {
    List<String> alerts = [];
    int cCount = widget.grades.values.where((g) => g == 'C' || g == 'C+' || g == 'C-').length;

    if (widget.interests.contains('Engineering') || widget.interests.contains('IT')) {
      final mathGrade = widget.grades['Math'] ?? widget.grades['Mathematics'];
      final scienceGrade = widget.grades['Physics'] ?? widget.grades['Chemistry'] ?? widget.grades['Science'] ?? widget.grades['Science/Physics'];
      if (mathGrade == 'C' || mathGrade == 'C+' || scienceGrade == 'C' || scienceGrade == 'C+') {
        alerts.add("⚠ Consider retaking Math/Science for strong Engineering/IT programs, or explore foundational courses.");
      }
    }

    if (cCount >= 2) {
      alerts.add("⚠ Your C grades may limit options for highly competitive programs. Consider adjusting your target.");
    }

    return alerts;
  }

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendations.isEmpty)
                const Text('No matches found. Check your grades or chat with AI Advisor for guidance.', style: TextStyle(color: Colors.grey))
              else
                ...recommendations.take(8).map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSimpleCourseCard(course),
                )),
            ],
          ),
        );
      },
    );
  }

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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF673AB7), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "${course.universityName} • ${course.location}",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "RM ${course.annualFee.toStringAsFixed(0)} / year",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (course.muetBand != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    "MUET Band ${course.muetBand}",
                    style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          )
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