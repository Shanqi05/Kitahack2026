class StudentProfile {
  final String qualification; // SPM, STPM, Matrikulasi, Asasi, Diploma
  final bool upu; // true if applying via UPU
  final List<String> interests; // IT, Engineering, etc.
  final Map<String, String> spmGrades; // subject: grade
  final Map<String, String>? stpmGrades; // optional
  final Map<String, String>? preUniGrades; // Matrikulasi / Asasi / Diploma
  final double? budget; // optional budget

  StudentProfile({
    required this.qualification,
    required this.upu,
    required this.interests,
    required this.spmGrades,
    this.stpmGrades,
    this.preUniGrades,
    this.budget,
  });
}
