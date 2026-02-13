import '../models/course_model.dart';
import '../models/university_model.dart';
import '../models/program_model.dart';
import 'course_repository.dart';

class RecommendedProgram {
  final String courseName;
  final String courseId;
  final String universityName;
  final String universityId;
  final String location;
  final String level;
  final double annualFee;
  final String interestField;
  final int? minMerit;
  final double matchScore;

  RecommendedProgram({
    required this.courseName,
    required this.courseId,
    required this.universityName,
    required this.universityId,
    required this.location,
    required this.level,
    required this.annualFee,
    required this.interestField,
    this.minMerit,
    required this.matchScore,
  });
}

class AdmissionEngine {
  final CourseRepository repository;

  AdmissionEngine({required this.repository});

  /// Recommend courses based on student profile
  List<RecommendedProgram> getRecommendations({
    required String qualification,
    required bool upu,
    required Map<String, String> grades,
    required List<String> interests,
    double? budget,
  }) {
    final programs = repository.programs;

    // Filter programs by interests and entry mode
    List<ProgramModel> programsFiltered = programs.where((p) {
      final interestMatch = interests.contains(p.interestField);
      final entryModeMatch = upu ? p.entryMode.contains("UPU") : !p.entryMode.contains("UPU");
      return interestMatch && entryModeMatch;
    }).toList();

    // Filter by budget if provided
    if (budget != null) {
      programsFiltered = programsFiltered.where((p) => p.annualFee <= budget).toList();
    }

    // Create a map of universities and courses for quick lookup
    final universitiesMap = {
      for (var uni in repository.universities) uni.id: uni
    };
    final coursesMap = {
      for (var course in repository.courses) course.id: course
    };

    // Convert to recommended programs and score them
    List<RecommendedProgram> recommendations = [];

    for (var program in programsFiltered) {
      final course = coursesMap[program.courseId];
      final university = universitiesMap[program.universityId];

      if (course != null && university != null) {
        double matchScore = _calculateMatchScore(
          interests,
          program.interestField,
          program.level,
          program.annualFee,
          budget,
        );

        recommendations.add(
          RecommendedProgram(
            courseName: course.name,
            courseId: course.id,
            universityName: university.name,
            universityId: university.id,
            location: university.location,
            level: program.level,
            annualFee: program.annualFee,
            interestField: program.interestField,
            minMerit: program.minMerit,
            matchScore: matchScore,
          ),
        );
      }
    }

    // Sort by match score (highest first) and return top 10
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations.take(10).toList();
  }

  double _calculateMatchScore(
    List<String> interests,
    String programField,
    String level,
    double fee,
    double? budget,
  ) {
    double score = 0.0;

    // Check if program field matches interests
    if (interests.contains(programField)) {
      score += 50;
    }

    // Prefer degree level
    if (level.toLowerCase() == 'degree') {
      score += 15;
    } else if (level.toLowerCase() == 'diploma' ||
        level.toLowerCase() == 'foundation') {
      score += 10;
    }

    // Add budget bonus if within range
    if (budget != null && fee <= budget) {
      score += 25;
    }

    // Base score
    score += 10;

    return score;
  }
}
