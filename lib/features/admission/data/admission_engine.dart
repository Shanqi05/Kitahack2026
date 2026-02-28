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
  final double? minMerit;
  final double? muetBand;
  final double? studentMerit;
  final bool meetsRequirement;
  final double matchScore;

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
    this.muetBand,
    this.studentMerit,
    this.meetsRequirement = true,
    required this.matchScore,
  }) {
    course = CourseModel(
      id: courseId,
      name: courseName,
      field: interestField,
      level: [level],
      minMeritRequired: minMerit,
    );
  }
}

class AdmissionEngine {
  final CourseRepository? repository;

  AdmissionEngine({this.repository});

  List<RecommendedProgram> getRecommendations(StudentProfile student) {
    if (repository == null) {
      return [];
    }

    double? studentMerit;
    try {
      if (student.qualification.toLowerCase() == 'spm' && student.isUpu) {
        studentMerit = MeritCalculator.calculateSpmMerit(
          compulsoryMarks: student.spmCompulsoryMarks ?? [],
          electiveMarks: student.spmElectiveMarks ?? [],
          additionalMarks: student.spmAdditionalMarks ?? [],
          coCurricularMark: student.coCurricularMark,
        );
      } else if (['stpm', 'asasi', 'matrikulasi'].contains(student.qualification.toLowerCase())) {
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
      print('Merit calculation error: $e');
    }

    double? studentMuet;
    if (student.spmGrades != null && student.spmGrades!['MUET'] != null) {
      String muetStr = student.spmGrades!['MUET']!.replaceAll(RegExp(r'[^0-9.]'), '');
      studentMuet = double.tryParse(muetStr);
    }

    final programs = repository!.programs;
    final coursesMap = {for (var course in repository!.courses) course.id: course};
    final universitiesMap = {for (var uni in repository!.universities) uni.id: uni};

    List<ProgramModel> filtered = programs.where((p) {
      return _isValidLevelForQualification(student, p.level) &&
          _isValidEntryMode(student, p.entryMode);
    }).toList();

    //  2.  (Soft Filtering)

    if (student.interest.isNotEmpty) {
      var intFiltered = filtered.where((p) => student.interest.any((i) => p.interestField.toLowerCase().contains(i.toLowerCase()))).toList();
      if (intFiltered.isNotEmpty) filtered = intFiltered; // 如果匹配后不为空，才应用过滤
    }


    if (student.budget != null) {
      var bFiltered = filtered.where((p) => p.annualFee <= student.budget!).toList();
      if (bFiltered.isNotEmpty) filtered = bFiltered;
    }


    var sFiltered = filtered.where((p) => _isValidCourseForStream(student, p.interestField, p.courseId)).toList();
    if (sFiltered.isNotEmpty) filtered = sFiltered;


    if (studentMerit != null && student.isUpu) {
      var mFiltered = filtered.where((p) => p.minMerit == null || studentMerit! >= p.minMerit!).toList();
      if (mFiltered.isNotEmpty) filtered = mFiltered;
    }


    if (studentMuet != null) {
      var muetFiltered = filtered.where((p) => p.muetBand == null || studentMuet! >= p.muetBand!).toList();
      if (muetFiltered.isNotEmpty) filtered = muetFiltered;
    }

    List<RecommendedProgram> recommendations = [];

    for (var program in filtered) {
      final course = coursesMap[program.courseId];
      final university = universitiesMap[program.universityId];

      if (course != null && university != null) {
        double matchScore = _calculateMatchScore(
          student.interest, program.interestField, program.level,
          program.annualFee, student.budget, student.spmGrades, program.minMerit,
        );

        bool meetsRequirement = true;
        if (studentMerit != null && program.minMerit != null) {
          meetsRequirement = studentMerit >= program.minMerit!;
        }

        recommendations.add(
          RecommendedProgram(
            courseName: course.name, courseId: course.id,
            universityName: university.name, universityId: university.id,
            location: university.location, level: program.level,
            annualFee: program.annualFee, interestField: program.interestField,
            minMerit: program.minMerit, muetBand: program.muetBand,
            studentMerit: studentMerit, meetsRequirement: meetsRequirement, matchScore: matchScore,
          ),
        );
      }
    }


    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations.take(10).toList();
  }

  bool _isValidLevelForQualification(StudentProfile student, String level) {
    switch (student.qualification) {
      case 'SPM': return student.isUpu ? ['Diploma', 'Asasi'].contains(level) : ['Foundation'].contains(level);
      case 'STPM': case 'Matrikulasi': case 'Asasi': case 'Diploma': return ['Degree'].contains(level);
      default: return true;
    }
  }

  bool _isValidEntryMode(StudentProfile student, List<String> programEntryModes) {
    List<String> validEntryModes = [];
    switch (student.qualification) {
      case 'SPM': validEntryModes = student.isUpu ? ['SPM_UPU'] : ['SPM_Direct']; break;
      case 'STPM': validEntryModes = student.isUpu ? ['STPM_UPU'] : ['STPM_Direct']; break;
      case 'Matrikulasi': validEntryModes = student.isUpu ? ['Matrikulasi_UPU'] : ['Matrikulasi_Direct']; break;
      case 'Asasi': validEntryModes = student.isUpu ? ['Asasi_UPU'] : ['Asasi_Direct']; break;
      case 'Diploma': validEntryModes = student.isUpu ? ['Diploma_UPU'] : ['Diploma_Direct']; break;
      default: return true;
    }
    return programEntryModes.any((mode) => validEntryModes.contains(mode));
  }

  bool _isValidCourseForStream(StudentProfile student, String field, String courseId) {
    if (!['STPM', 'Asasi', 'Matrikulasi'].contains(student.qualification)) return true;
    if (student.stream == 'Science') return true;
    if (student.stream == 'Commerce' || student.stream == 'Account' || student.stream == 'Economy') {
      final scienceOnlyCourses = ['CS', 'AI', 'DS', 'CS_SEC', 'SOFTENG', 'BIOTECH', 'GENETIC', 'MEDIC_BCS', 'MECH', 'ELEC', 'CIVIL', 'CHEM_ENG', 'BIOMEDIC', 'PHARMA', 'NURSE'];
      return !scienceOnlyCourses.contains(courseId);
    }
    if (student.stream == 'Arts') {
      final artsAllowedCourses = ['ART', 'DESIGN', 'COMM', 'ENG', 'HISTORY', 'LANG', 'HBP', 'BUS', 'PSYCH', 'LAW', 'SOCIAL'];
      return artsAllowedCourses.contains(courseId) || ['Arts', 'Communication', 'Business', 'Law'].any((f) => field.toLowerCase().contains(f.toLowerCase()));
    }
    return true;
  }

  double _calculateMatchScore(
      List<String> interests, String programField, String level, double fee,
      double? budget, Map<String, String>? grades, double? minMerit,
      ) {
    double score = 0.0;
    final exactMatch = interests.any((i) => programField.toLowerCase().contains(i.toLowerCase()) || i.toLowerCase().contains(programField.toLowerCase()));
    if (exactMatch) score += 50;
    else score += 20;
    if (level.toLowerCase() == 'degree') score += 20;
    else score += 15;
    if (budget != null && fee <= budget) score += 15;
    return score + 10;
  }
}