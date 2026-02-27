import 'course_model.dart';
import 'university_model.dart';

/// Result object returned by the AdmissionEngine
/// Contains the top recommended courses and the universities offering them
class RecommendationResult {
  /// List of top recommended courses (max 3)
  final List<CourseModel> recommendedCourses;

  /// Map of courseId -> list of universities offering this course
  final Map<String, List<UniversityModel>> universitiesPerCourse;

  RecommendationResult({
    required this.recommendedCourses,
    required this.universitiesPerCourse,
  });

  /// Convert to JSON (optional, useful for sending to frontend/UI)
  Map<String, dynamic> toJson() {
    return {
      'recommendedCourses': recommendedCourses.map((c) => c.toJson()).toList(),
      'universitiesPerCourse': universitiesPerCourse.map(
        (courseId, uniList) => MapEntry(
          courseId,
          uniList.map((u) => u.toJson()).toList(),
        ),
      ),
    };
  }
}
