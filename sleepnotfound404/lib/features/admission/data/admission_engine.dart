import '../models/student_profile.dart';
import '../models/course_model.dart';
import '../models/university_model.dart';
import '../models/recommendation_result.dart';
import 'course_repository.dart';
import '../../../core/utils/merit_calculator.dart'; 

class AdmissionEngine {
  final CourseRepository repository;

  AdmissionEngine({required this.repository});

  /// Recommend courses and universities based on student profile
  Future<RecommendationResult> recommend(StudentProfile student) async {
    // Load programs from repository
    final programs = repository.programs;

    // 1️⃣ Filter programs by student interests
    List programsFiltered = programs.where((p) {
      final interestMatch = student.interests.contains(p.interestField);
      final upuMatch = !student.upu || p.entryMode.contains("UPU") || (!student.upu && !p.entryMode.contains("UPU"));
      return interestMatch && upuMatch;
    }).toList();

    // 2️⃣ Filter by merit if applying via UPU
    if (student.upu) {
      programsFiltered = programsFiltered.where((p) {
        if (p.minMerit == null) return true; // skip private uni
        final merit = MeritCalculator.calculateMerit(
          spmGrades: student.spmGrades,
          stpmGrades: student.stpmGrades,
          preUniGrades: student.preUniGrades,
        );
        return merit >= p.minMerit!;
      }).toList();
    }

    // 3️⃣ Filter by budget if provided
    if (student.budget != null) {
      programsFiltered = programsFiltered.where((p) => p.annualFee <= student.budget!).toList();
    }

    // 4️⃣ Pick top 3 courses
    final Map<String, CourseModel> courseMap = {for (var c in repository.courses) c.id: c};
    final topCourses = <CourseModel>[];
    final universitiesPerCourse = <String, List<UniversityModel>>{};

    for (var p in programsFiltered) {
      if (topCourses.length >= 3) break;

      // Add course if not already selected
      if (!topCourses.any((c) => c.id == p.courseId)) {
        final course = courseMap[p.courseId];
        if (course != null) {
          topCourses.add(course);

          // Find universities offering this course
          universitiesPerCourse[p.courseId] = repository.universities
              .where((u) => programsFiltered.any((fp) => fp.courseId == p.courseId && fp.universityId == u.id))
              .toList();
        }
      }
    }

    return RecommendationResult(
      recommendedCourses: topCourses,
      universitiesPerCourse: universitiesPerCourse,
    );
  }
}
