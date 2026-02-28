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
    required List<int> compulsoryMarks,
    required List<int> electiveMarks,
    required List<int> additionalMarks,
    required double coCurricularMark,
  }) {
    // ------------------------------
    // 智能容错处理 (Auto-Padding)
    // ------------------------------
    if (coCurricularMark < 0 || coCurricularMark > 10) {
      coCurricularMark = 0; // 防止课外活动分数填错导致崩溃
    }

    // 如果科目不够，自动补 0 分 (G)；如果超过，只取需要的前几个
    List<int> safeCompulsory = List.from(compulsoryMarks);
    while (safeCompulsory.length < 4) safeCompulsory.add(0);

    List<int> safeElective = List.from(electiveMarks);
    while (safeElective.length < 2) safeElective.add(0);

    List<int> safeAdditional = List.from(additionalMarks);
    if (safeAdditional.length > 2) {
      // 附加科目如果超过2个，自动选分数最高的2个
      safeAdditional.sort((a, b) => b.compareTo(a));
      safeAdditional = safeAdditional.take(2).toList();
    }

    // ------------------------------
    // Sum raw marks
    // ------------------------------
    final int compulsoryTotal =
    safeCompulsory.take(4).fold(0, (sum, mark) => sum + mark);

    final int electiveTotal =
    safeElective.take(2).fold(0, (sum, mark) => sum + mark);

    final int additionalTotal =
    safeAdditional.fold(0, (sum, mark) => sum + mark);

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
    safeAdditional.isEmpty
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
    double safeCgpa = cgpa;
    if (safeCgpa < 0) safeCgpa = 0.0;
    if (safeCgpa > 4.0) safeCgpa = 4.0;

    double safeKoko = coCurricularMark;
    if (safeKoko < 0) safeKoko = 0.0;
    if (safeKoko > 10) safeKoko = 10.0;

    final double cgpaConverted = (safeCgpa / 4.0) * 90;

    return cgpaConverted + safeKoko;
  }

  // ==============================
  // DIPLOMA CALCULATION
  // ==============================
  //
  // CGPA converted directly to 100%

  static double calculateDiplomaMerit({
    required double cgpa, // 0.0 – 4.0
  }) {
    double safeCgpa = cgpa;
    if (safeCgpa < 0) safeCgpa = 0.0;
    if (safeCgpa > 4.0) safeCgpa = 4.0;

    return (safeCgpa / 4.0) * 100;
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
        return 0.0; // Fail-safe
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