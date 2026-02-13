import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/course_repository.dart';
import '../data/admission_engine.dart';
import '../models/student_profile.dart';

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

  @override
  void initState() {
    super.initState();
    _getRecommendations = _loadRecommendations();
  }

  Future<List<RecommendedProgram>> _loadRecommendations() async {
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
    final recommendations = engine.getRecommendations(student);

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Recommendations"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: FutureBuilder<List<RecommendedProgram>>(
        future: _getRecommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recommendations = snapshot.data ?? [];

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10),
                      const Text(
                        'Top Recommended Courses',
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
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            const Text(
                              'Analysis Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Qualification',
                              widget.qualification,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Application Mode',
                              widget.upu ? 'UPU' : 'Direct/Private',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Interests',
                              widget.interests.join(', '),
                            ),
                            if (widget.budget != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Budget',
                                'RM ${widget.budget?.toStringAsFixed(0)}',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            const Text(
                              'Recommended Courses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF673AB7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (recommendations.isEmpty)
                              const Text(
                                'No courses found matching your criteria. Try adjusting your budget or interests.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF673AB7),
                                ),
                              )
                            else ...[
                              Text(
                                'Top ${recommendations.length.clamp(0, 3)} courses matching your profile:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...recommendations
                                  .take(3)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) {
                                    final index = e.key + 1;
                                    final course = e.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildCourseCard(index, course),
                                    );
                                  })
                                  .toList(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (widget.resumeFile != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              const Text(
                                'Resume Analyzed',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.resumeFile?.name ?? 'Resume file',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700] ?? Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Back to Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(int index, RecommendedProgram course) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF673AB7).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF673AB7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.universityName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.location,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'RM ${course.annualFee.toStringAsFixed(0)}/year',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
