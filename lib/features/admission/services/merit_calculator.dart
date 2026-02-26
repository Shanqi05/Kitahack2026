

class MeritCalculator {
  // ==============================
  // SPM MERIT CALCULATION (UPU)
  // ==============================
  //
  // Weightage:
  // Compulsory (4 subjects)  = 40%
  // Elective (2 subjects)    = 30%
  // Additional (max 2)       = 10%
  // Academic Total           = 80%
  // Co-curricular            = 10%
  //
  // Final Formula:
  // ((Academic / 80) * 90) + Co-curricular
  //
  // Grade system assumed:
  // A+ = 18 ... G = 0

  static double calculateSpmMerit({
    required List<int> compulsoryMarks,   // exactly 4 subjects
    required List<int> electiveMarks,     // exactly 2 subjects
    required List<int> additionalMarks,   // 0–2 subjects
    required double coCurricularMark,     // 0–10
  }) {
    // ------------------------------
    // Validation
    // ------------------------------
    if (coCurricularMark < 0 || coCurricularMark > 10) {
      throw ArgumentError('Co-curricular mark must be between 0 and 10.');
    }

    if (compulsoryMarks.length != 4) {
      throw ArgumentError('Compulsory subjects must contain exactly 4 marks.');
    }

    if (electiveMarks.length != 2) {
      throw ArgumentError('Elective subjects must contain exactly 2 marks.');
    }

    if (additionalMarks.length > 2) {
      throw ArgumentError('Additional subjects can have a maximum of 2 marks.');
    }

    // ------------------------------
    // Sum raw marks
    // ------------------------------
    final int compulsoryTotal =
        compulsoryMarks.fold(0, (sum, mark) => sum + mark);

    final int electiveTotal =
        electiveMarks.fold(0, (sum, mark) => sum + mark);

    final int additionalTotal =
        additionalMarks.fold(0, (sum, mark) => sum + mark);

    // ------------------------------
    // Maximum possible marks
    // (A+ = 18 per subject)
    // ------------------------------
    const double compulsoryMax = 4 * 18; // 72
    const double electiveMax = 2 * 18;   // 36
    const double additionalMax = 2 * 18; // 36

    // ------------------------------
    // Apply official weightage
    // ------------------------------
    final double compulsoryWeighted =
        (compulsoryTotal / compulsoryMax) * 40;

    final double electiveWeighted =
        (electiveTotal / electiveMax) * 30;

    final double additionalWeighted =
        additionalMarks.isEmpty
            ? 0
            : (additionalTotal / additionalMax) * 10;

    // Academic total (max 80)
    final double academicTotal =
        compulsoryWeighted + electiveWeighted + additionalWeighted;

    // Final Merit (max 100)
    final double finalMerit =
        ((academicTotal / 80) * 90) + coCurricularMark;

    return finalMerit;
  }

  // ==========================================
  // STPM / ASASI / MATRICULATION CALCULATION
  // ==========================================
  //
  // CGPA = 90%
  // Co-curricular = 10%
  //
  // Formula:
  // (CGPA / 4.0 * 90) + Co-curricular

  static double calculatePreUniversityMerit({
    required double cgpa,               // 0.0 – 4.0
    required double coCurricularMark,   // 0 – 10
  }) {
    if (cgpa < 0 || cgpa > 4.0) {
      throw ArgumentError('CGPA must be between 0.0 and 4.0.');
    }

    if (coCurricularMark < 0 || coCurricularMark > 10) {
      throw ArgumentError('Co-curricular mark must be between 0 and 10.');
    }

    final double cgpaConverted = (cgpa / 4.0) * 90;

    return cgpaConverted + coCurricularMark;
  }

  // ==============================
  // DIPLOMA CALCULATION
  // ==============================
  //
  // CGPA converted directly to 100%

  static double calculateDiplomaMerit({
    required double cgpa, // 0.0 – 4.0
  }) {
    if (cgpa < 0 || cgpa > 4.0) {
      throw ArgumentError('CGPA must be between 0.0 and 4.0.');
    }

    return (cgpa / 4.0) * 100;
  }

  // ==================================
  // MAIN MERIT ROUTER
  // ==================================

  static double calculateMerit({
    required String qualification, // SPM, STPM, Asasi, Matrikulasi, Diploma
    required bool isUpu,
    List<int>? compulsoryMarks,
    List<int>? electiveMarks,
    List<int>? additionalMarks,
    double? cgpa,
    required double coCurricularMark,
  }) {
    switch (qualification.toLowerCase()) {
      case 'spm':
        if (!isUpu) {
          throw ArgumentError(
            'SPM merit calculation is only applicable for UPU platform.',
          );
        }
        return calculateSpmMerit(
          compulsoryMarks: compulsoryMarks ?? [],
          electiveMarks: electiveMarks ?? [],
          additionalMarks: additionalMarks ?? [],
          coCurricularMark: coCurricularMark,
        );

      case 'stpm':
      case 'asasi':
      case 'matrikulasi':
        return calculatePreUniversityMerit(
          cgpa: cgpa ?? 0.0,
          coCurricularMark: coCurricularMark,
        );

      case 'diploma':
        return calculateDiplomaMerit(
          cgpa: cgpa ?? 0.0,
        );

      default:
        throw ArgumentError('Unknown qualification type: $qualification');
    }
  }

  // ==================================
  // COURSE REQUIREMENT CHECK
  // ==================================

  static bool meetsRequirement({
    required double studentMerit,
    required double courseMinMerit,
  }) {
    return studentMerit >= courseMinMerit;
  }
}
