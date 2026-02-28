import 'merit_calculator.dart';

class MeritUtility {
  /// Calculate merit and return a formatted string for display
  static String calculateAndFormatMerit({
    required String qualification,
    required bool isUpu,
    List<int>? spmCompulsoryMarks,
    List<int>? spmElectiveMarks,
    List<int>? spmAdditionalMarks,
    double? cgpa,
    double coCurricularMark = 0.0,
  }) {
    try {
      double merit = MeritCalculator.calculateMerit(
        qualification: qualification,
        isUpu: isUpu,
        compulsoryMarks: spmCompulsoryMarks,
        electiveMarks: spmElectiveMarks,
        additionalMarks: spmAdditionalMarks,
        cgpa: cgpa,
        coCurricularMark: coCurricularMark,
      );

      return merit.toStringAsFixed(2);
    } catch (e) {
      return 'N/A';
    }
  }

  /// Get eligibility status for a course
  static String getEligibilityStatus({
    required double studentMerit,
    required double? courseMinMerit,
  }) {
    if (courseMinMerit == null) {
      return 'Eligible';
    }

    if (studentMerit >= courseMinMerit) {
      double excess = studentMerit - courseMinMerit;
      return 'Eligible (+${excess.toStringAsFixed(1)} points)';
    } else {
      double shortfall = courseMinMerit - studentMerit;
      return 'Not Eligible (-${shortfall.toStringAsFixed(1)} points)';
    }
  }

  /// Get eligibility color for UI display
  static String getEligibilityColor({
    required double studentMerit,
    required double? courseMinMerit,
  }) {
    if (courseMinMerit == null) {
      return 'green'; // No requirement
    }

    if (studentMerit >= courseMinMerit) {
      return 'green'; // Eligible
    } else if (studentMerit >= courseMinMerit - 5) {
      return 'orange'; // Close to requirement
    } else {
      return 'red'; // Not eligible
    }
  }

  /// Calculate required marks for SPM to meet a certain merit target
  static Map<String, dynamic> calculateRequiredSpmMarks({
    required double targetMerit,
    required double coCurricularMark,
    required int numCompulsory,
    required int numElective,
    required int numAdditional,
  }) {
    // Academic part = targetMerit - coCurricularMark
    double requiredAcada = targetMerit - coCurricularMark;

    // From formula: (academic / 80) * 90 = requiredAcada
    // So: academic = (requiredAcada / 90) * 80
    double requiredAcademicScore = (requiredAcada / 90) * 80;

    // Average mark needed per subject
    int totalSubjects = numCompulsory + numElective + numAdditional;
    double averageMarkNeeded = requiredAcademicScore / totalSubjects;

    return {
      'targetMerit': targetMerit,
      'requiredAcademicScore': requiredAcademicScore.toStringAsFixed(2),
      'totalSubjects': totalSubjects,
      'averageMarkNeeded': averageMarkNeeded.toStringAsFixed(2),
      'achievable': requiredAcademicScore <= 80.0,
    };
  }

  /// Calculate required CGPA for pre-university to meet a certain merit target
  static Map<String, dynamic> calculateRequiredCgpaForPreUniversity({
    required double targetMerit,
    required double coCurricularMark,
  }) {
    // From formula: (cgpa / 4.0) * 90 + coCurricularMark = targetMerit
    // So: (cgpa / 4.0) * 90 = targetMerit - coCurricularMark
    // cgpa = ((targetMerit - coCurricularMark) / 90) * 4.0

    double requiredCgpa = ((targetMerit - coCurricularMark) / 90) * 4.0;

    return {
      'targetMerit': targetMerit,
      'requiredCgpa': requiredCgpa.toStringAsFixed(2),
      'achievable': requiredCgpa <= 4.0 && requiredCgpa >= 0.0,
    };
  }

  /// Calculate required CGPA for diploma to meet a certain merit target
  static Map<String, dynamic> calculateRequiredCgpaForDiploma({
    required double targetMerit,
  }) {
    // From formula: (cgpa / 4.0) * 100 = targetMerit
    // So: cgpa = (targetMerit / 100) * 4.0

    double requiredCgpa = (targetMerit / 100) * 4.0;

    return {
      'targetMerit': targetMerit,
      'requiredCgpa': requiredCgpa.toStringAsFixed(2),
      'achievable': requiredCgpa <= 4.0 && requiredCgpa >= 0.0,
    };
  }

  /// Format merit score with grade classification
  static String getMeritGrade(double merit) {
    if (merit >= 90) {
      return 'A (Excellent)';
    } else if (merit >= 80) {
      return 'B (Very Good)';
    } else if (merit >= 70) {
      return 'C (Good)';
    } else if (merit >= 60) {
      return 'D (Satisfactory)';
    } else if (merit >= 50) {
      return 'E (Pass)';
    } else {
      return 'F (Fail)';
    }
  }

  /// Get merit percentile (rough estimate)
  static String getMeritPercentile(double merit) {
    if (merit >= 95) {
      return 'Top 5%';
    } else if (merit >= 90) {
      return 'Top 15%';
    } else if (merit >= 80) {
      return 'Top 30%';
    } else if (merit >= 70) {
      return 'Top 50%';
    } else if (merit >= 60) {
      return 'Top 70%';
    } else {
      return 'Below Average';
    }
  }
}
