import '../models/course_model.dart';
import '../models/program_model.dart';
import '../models/student_profile.dart';
import 'course_repository.dart';
import '../services/merit_calculator.dart';

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
  final double? studentMerit; // Student's calculated merit score
  final bool meetsRequirement; // Whether student meets minimum merit
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
    this.studentMerit,
    this.meetsRequirement = true,
    required this.matchScore,
  }) {
    course = CourseModel(
      id: courseId,
      name: courseName,
      field: interestField,
      level: [level],
      minMeritRequired: minMerit?.toDouble(),
    );
  }
}

class AdmissionEngine {
  final CourseRepository? repository;

  AdmissionEngine({this.repository});

  /// Recommend courses based on student profile with detailed filtering
  List<RecommendedProgram> getRecommendations(StudentProfile student) {
    if (repository == null) {
      return _getMockRecommendations(student);
    }

    // Calculate student's merit if applicable
    double? studentMerit;
    try {
      if (student.qualification.toLowerCase() == 'spm' && student.isUpu) {
        studentMerit = MeritCalculator.calculateSpmMerit(
          compulsoryMarks: student.spmCompulsoryMarks ?? [],
          electiveMarks: student.spmElectiveMarks ?? [],
          additionalMarks: student.spmAdditionalMarks ?? [],
          coCurricularMark: student.coCurricularMark,
        );
      } else if ([
        'stpm',
        'asasi',
        'matrikulasi',
      ].contains(student.qualification.toLowerCase())) {
        studentMerit = MeritCalculator.calculatePreUniversityMerit(
          cgpa: student.cgpa ?? 0.0,
          coCurricularMark: student.coCurricularMark,
        );
      } else if (student.qualification.toLowerCase() == 'diploma') {
        studentMerit = MeritCalculator.calculateDiplomaMerit(
          cgpa: student.cgpa ?? 0.0,
        );
      }
    } catch (e) {
      // If merit calculation fails, continue without merit filtering
      print('Merit calculation error: $e');
    }

    final programs = repository!.programs;
    final coursesMap = {
      for (var course in repository!.courses) course.id: course,
    };
    final universitiesMap = {
      for (var uni in repository!.universities) uni.id: uni,
    };

    // Step 1: Filter by level based on qualification and mode
    List<ProgramModel> filtered = programs.where((p) {
      return _isValidLevelForQualification(student, p.level) &&
          _isValidEntryMode(student, p.entryMode);
    }).toList();

    // Step 2: Filter by field (interests)
    filtered = filtered.where((p) {
      return student.interest.any(
        (interest) =>
            p.interestField.toLowerCase().contains(interest.toLowerCase()),
      );
    }).toList();

    // Step 3: Filter by budget if provided
    if (student.budget != null) {
      filtered = filtered.where((p) => p.annualFee <= student.budget!).toList();
    }

    // Step 4: Filter by stream restrictions (for STPM, Asasi, Matriculation)
    filtered = filtered.where((p) {
      return _isValidCourseForStream(student, p.interestField, p.courseId);
    }).toList();

    // Step 5: If Diploma, only allow related degree courses in same field
    if (student.qualification == 'Diploma' && student.diplomaField != null) {
      filtered = filtered.where((p) {
        return p.interestField.toLowerCase() ==
            student.diplomaField!.toLowerCase();
      }).toList();
    }

    // Step 6: Filter by merit requirement if merit is calculated and UPU
    if (studentMerit != null &&
        student.isUpu &&
        student.qualification.toLowerCase() == 'spm') {
      filtered = filtered.where((p) {
        if (p.minMerit == null || studentMerit == null) {
          return true; // No merit requirement filter if minMerit or studentMerit is not set
        }
        return studentMerit! >= p.minMerit!;
      }).toList();
    }

    // Convert to recommendations with scoring
    List<RecommendedProgram> recommendations = [];

    for (var program in filtered) {
      final course = coursesMap[program.courseId];
      final university = universitiesMap[program.universityId];

      if (course != null && university != null) {
        double matchScore = _calculateMatchScore(
          student.interest,
          program.interestField,
          program.level,
          program.annualFee,
          student.budget,
          student.spmGrades,
          program.minMerit,
        );

        // Check if student meets merit requirement
        bool meetsRequirement = true;
        if (studentMerit != null && program.minMerit != null) {
          meetsRequirement = studentMerit >= program.minMerit!;
        }

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
            studentMerit: studentMerit,
            meetsRequirement: meetsRequirement,
            matchScore: matchScore,
          ),
        );
      }
    }

    // Sort by match score and return top 10
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations.take(10).toList();
  }

  /// Check if the level is valid for the student's qualification
  bool _isValidLevelForQualification(StudentProfile student, String level) {
    switch (student.qualification) {
      case 'SPM':
        if (student.isUpu) {
          // SPM + UPU → only Diploma and Asasi
          return ['Diploma', 'Asasi'].contains(level);
        } else {
          // SPM + Direct (Private) → only Foundation
          return ['Foundation'].contains(level);
        }
      case 'STPM':
      case 'Matrikulasi':
      case 'Asasi':
        // Can choose any Degree course
        return ['Degree'].contains(level);
      case 'Diploma':
        // Can choose Degree courses only (of same field)
        return ['Degree'].contains(level);
      default:
        return true;
    }
  }

  /// Check if the program's entry_mode matches the student's qualification and pathway
  bool _isValidEntryMode(
    StudentProfile student,
    List<String> programEntryModes,
  ) {
    // Determine which entry modes are valid for this student
    List<String> validEntryModes = [];

    switch (student.qualification) {
      case 'SPM':
        if (student.isUpu) {
          validEntryModes = ['SPM_UPU'];
        } else {
          validEntryModes = ['SPM_Direct'];
        }
        break;
      case 'STPM':
        if (student.isUpu) {
          validEntryModes = ['STPM_UPU'];
        } else {
          validEntryModes = ['STPM_Direct'];
        }
        break;
      case 'Matrikulasi':
        if (student.isUpu) {
          validEntryModes = ['Matrikulasi_UPU'];
        } else {
          validEntryModes = ['Matrikulasi_Direct'];
        }
        break;
      case 'Asasi':
        if (student.isUpu) {
          validEntryModes = ['Asasi_UPU'];
        } else {
          validEntryModes = ['Asasi_Direct'];
        }
        break;
      case 'Diploma':
        if (student.isUpu) {
          validEntryModes = ['Diploma_UPU'];
        } else {
          validEntryModes = ['Diploma_Direct'];
        }
        break;
      default:
        // If no specific pathway, allow all entry modes
        return true;
    }

    // Check if any of the program's entry modes match the student's valid modes
    return programEntryModes.any((mode) => validEntryModes.contains(mode));
  }

  /// Check if course is valid for student's stream
  bool _isValidCourseForStream(
    StudentProfile student,
    String field,
    String courseId,
  ) {
    // Only apply stream filtering to STPM, Asasi, Matriculation with Commerce stream
    if (!['STPM', 'Asasi', 'Matrikulasi'].contains(student.qualification)) {
      return true;
    }

    // If Science stream, all courses allowed
    if (student.stream == 'Science') {
      return true;
    }

    // If Commerce/Account/Economy stream, exclude science-only courses
    if (student.stream == 'Commerce' ||
        student.stream == 'Account' ||
        student.stream == 'Economy') {
      final scienceOnlyCourses = [
        'CS', 'AI', 'DS', 'CS_SEC', 'SOFTENG', // Computer Science
        'BIOTECH', 'GENETIC', 'MEDIC_BCS', // Biotech/Medical
        'MECH', 'ELEC', 'CIVIL', 'CHEM_ENG', // Engineering (Science-based)
        'BIOMEDIC', 'PHARMA', 'NURSE', // Health Science
      ];

      // Only allow if course is NOT in the science-only list
      return !scienceOnlyCourses.contains(courseId);
    }

    // Arts stream - allow specific courses
    if (student.stream == 'Arts') {
      final artsAllowedCourses = [
        'ART',
        'DESIGN',
        'COMM',
        'ENG',
        'HISTORY',
        'LANG',
        'HBP',
        'BUS',
        'PSYCH',
        'LAW',
        'SOCIAL',
      ];
      return artsAllowedCourses.contains(courseId) ||
          [
            'Arts',
            'Communication',
            'Business',
            'Law',
          ].any((field) => field.toLowerCase().contains(field.toLowerCase()));
    }

    return true;
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
        studentMerit: null,
        meetsRequirement: true,
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
            : ['Foundation']; // SPM non-UPU only gets Foundation
      case 'Matrikulasi':
        return ['Degree'];
      case 'STPM':
        return ['Degree'];
      case 'Asasi':
        return ['Degree'];
      case 'Diploma':
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
    Map<String, String>? grades,
    int? minMerit,
  ) {
    double score = 0.0;

    // Check if program field matches interests (exact match = higher score)
    final exactMatch = interests.any(
      (i) =>
          programField.toLowerCase().contains(i.toLowerCase()) ||
          i.toLowerCase().contains(programField.toLowerCase()),
    );
    if (exactMatch) {
      score += 50;
    } else {
      // Partial match for related fields
      final relatedInterests = _getRelatedFields(programField);
      if (interests.any(
        (i) => relatedInterests.any(
          (ri) => i.toLowerCase().contains(ri.toLowerCase()),
        ),
      )) {
        score += 30;
      }
    }

    // Prefer degree level
    if (level.toLowerCase() == 'degree') {
      score += 20;
    } else if (level.toLowerCase() == 'asasi' ||
        level.toLowerCase() == 'diploma' ||
        level.toLowerCase() == 'foundation') {
      score += 15;
    }

    // Add budget bonus if within range
    if (budget != null && fee <= budget) {
      score += 15;
    }

    // Grade performance bonus
    if (grades != null && grades.isNotEmpty) {
      final gradeScore = _calculateGradeScore(grades, programField, level);
      score += gradeScore;
    }

    // Merit requirement consideration
    if (minMerit != null && grades != null) {
      final studentMerit = _calculateStudentMerit(grades);
      if (studentMerit >= minMerit) {
        score += 10; // Student meets requirement
      } else if (studentMerit >= minMerit - 5) {
        score += 5; // Close to requirement
      }
    }

    // Base score
    score += 10;

    return score;
  }

  /// Get related fields for a program
  List<String> _getRelatedFields(String programField) {
    final relatedMap = {
      'IT': ['Technology', 'Science', 'Engineering'],
      'Engineering': ['Science', 'Technology', 'IT'],
      'Science': ['Engineering', 'Health Science'],
      'Health Science': ['Science', 'Psychology'],
      'Business': ['Finance', 'Accounting', 'Communication'],
      'Finance': ['Business', 'Accounting'],
      'Communication': ['Business', 'Arts'],
      'Arts': ['Communication', 'Design'],
    };
    return relatedMap[programField] ?? [];
  }

  /// Calculate grade score based on program requirements
  double _calculateGradeScore(
    Map<String, String> grades,
    String programField,
    String level,
  ) {
    double score = 0.0;
    final gradeValues = {
      'A+': 4.0,
      'A': 3.9,
      'A-': 3.7,
      'B+': 3.3,
      'B': 3.0,
      'B-': 2.7,
      'C+': 2.3,
      'C': 2.0,
      'C-': 1.7,
      'D': 1.0,
      'D+': 1.3,
      'E': 0.0,
      'A1': 4.0,
      'A2': 3.8,
      'B3': 3.3,
      'B4': 3.0,
      'B5': 2.7,
      'B6': 2.5,
      'C7': 2.0,
      'C8': 1.5,
      'F9': 0.0,
      'G': 0.5,
    };

    // Calculate GPA
    double gpaSum = 0;
    int validGrades = 0;
    for (var entry in grades.entries) {
      double? value = gradeValues[entry.value];
      if (value != null) {
        gpaSum += value;
        validGrades++;
      }
    }
    double gpa = validGrades > 0 ? gpaSum / validGrades : 0;

    // Score based on level
    if (level.toLowerCase() == 'degree') {
      if (gpa >= 3.5)
        score += 12;
      else if (gpa >= 3.0)
        score += 8;
      else if (gpa >= 2.5)
        score += 4;
    } else if ([
      'asasi',
      'foundation',
      'diploma',
    ].contains(level.toLowerCase())) {
      if (gpa >= 3.0)
        score += 10;
      else if (gpa >= 2.5)
        score += 6;
      else if (gpa >= 2.0)
        score += 3;
    }

    return score;
  }

  /// Calculate overall student merit based on grades
  int _calculateStudentMerit(Map<String, String> grades) {
    final gradeToNumber = {
      'A+': 100,
      'A': 95,
      'A-': 90,
      'B+': 85,
      'B': 80,
      'B-': 75,
      'C+': 70,
      'C': 65,
      'C-': 60,
      'D': 50,
      'D+': 55,
      'E': 40,
      'A1': 100,
      'A2': 95,
      'B3': 85,
      'B4': 80,
      'B5': 75,
      'B6': 70,
      'C7': 65,
      'C8': 60,
      'F9': 40,
      'G': 45,
    };

    double sum = 0;
    int count = 0;
    for (var entry in grades.entries) {
      int? value = gradeToNumber[entry.value];
      if (value != null) {
        sum += value;
        count++;
      }
    }
    return count > 0 ? (sum / count).round() : 0;
  }
}
