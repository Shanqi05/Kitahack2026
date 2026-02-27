import 'grade_converter.dart';

class MeritCalculator {
  // Calculate merit mark for UPU based on grades
  // Example: SPM + STPM + optional Matrikulasi/Asasi/Diploma
  static double calculateMerit({
    required Map<String, String> spmGrades,
    Map<String, String>? stpmGrades,
    Map<String, String>? preUniGrades,
  }) {
    int totalPoints = 0;
    int subjects = 0;

    spmGrades.forEach((subject, grade) {
      totalPoints += GradeConverter.spmGradeToPoint(grade);
      subjects++;
    });

    if (stpmGrades != null) {
      stpmGrades.forEach((subject, grade) {
        totalPoints += GradeConverter.stpmGradeToPoint(grade);
        subjects++;
      });
    }

    if (preUniGrades != null) {
      preUniGrades.forEach((subject, grade) {
        totalPoints += GradeConverter.spmGradeToPoint(grade);
        subjects++;
      });
    }

    return subjects > 0 ? totalPoints / subjects : 0;
  }
}
