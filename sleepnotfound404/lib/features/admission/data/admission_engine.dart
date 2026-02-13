import '../models/course_model.dart';
import '../models/program_model.dart';
import '../models/student_profile.dart';
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

  // New property for test compatibility
  late final CourseModel course;

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
  }) {
    course = CourseModel(
      id: courseId,
      name: courseName,
      field: interestField,
      level: [level],
    );
  }
}

class AdmissionEngine {
  final CourseRepository? repository;

  AdmissionEngine({this.repository});

  /// Recommend courses based on student profile
  List<RecommendedProgram> getRecommendations(StudentProfile student) {
    // If no repository, return mock recommendations based on qualification
    if (repository == null) {
      return _getMockRecommendations(student);
    }

    final programs = repository!.programs;

    // Filter programs by interests and entry mode
    List<ProgramModel> programsFiltered = programs.where((p) {
      final interestMatch = student.interest.contains(p.interestField);
      final entryModeMatch = student.isUpu
          ? p.entryMode.contains("UPU")
          : !p.entryMode.contains("UPU");
      return interestMatch && entryModeMatch;
    }).toList();

    // Filter by budget if provided
    if (student.budget != null) {
      programsFiltered = programsFiltered
          .where((p) => p.annualFee <= student.budget!)
          .toList();
    }

    // Create a map of universities and courses for quick lookup
    final universitiesMap = {
      for (var uni in repository!.universities) uni.id: uni,
    };
    final coursesMap = {
      for (var course in repository!.courses) course.id: course,
    };

    // Convert to recommended programs and score them
    List<RecommendedProgram> recommendations = [];

    for (var program in programsFiltered) {
      final course = coursesMap[program.courseId];
      final university = universitiesMap[program.universityId];

      if (course != null && university != null) {
        double matchScore = _calculateMatchScore(
          student.interest,
          program.interestField,
          program.level,
          program.annualFee,
          student.budget,
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

  /// Generate mock recommendations for testing when no repository is available
  List<RecommendedProgram> _getMockRecommendations(StudentProfile student) {
    final levels = _getLevelsByQualification(
      student.qualification,
      student.isUpu,
    );
    final field = student.interest.isNotEmpty
        ? student.interest.first
        : 'General';

    return [
      RecommendedProgram(
        courseName: '${field} Program',
        courseId: 'mock_001',
        universityName: 'Test University',
        universityId: 'uni_001',
        location: 'Malaysia',
        level: levels.isNotEmpty ? levels.first : 'Diploma',
        annualFee: 5000.0,
        interestField: field,
        minMerit: null,
        matchScore: 100.0,
      ),
    ];
  }

  /// Determine education levels based on qualification
  List<String> _getLevelsByQualification(String qualification, bool isUpu) {
    switch (qualification) {
      case 'SPM':
        return isUpu
            ? ['Asasi', 'Diploma']
            : ['Diploma', 'Foundation', 'A-Level'];
      case 'Matrikulasi':
        return ['Degree'];
      case 'STPM':
        return ['Degree'];
      case 'A-Level':
        return ['Degree'];
      default:
        return ['Diploma', 'Degree'];
    }
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
