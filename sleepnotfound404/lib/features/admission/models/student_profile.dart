class StudentProfile {
  final String qualification; // SPM, STPM, Matrikulasi, Asasi, Diploma
  final bool isUpu; // true if applying via UPU
  final List<String> interest; // IT, Engineering, etc.
  final Map<String, String>? spmGrades; // subject: grade
  final Map<String, String>? stpmGrades; // optional
  final Map<String, String>? preUniGrades; // Matrikulasi / Asasi / Diploma
  final double? budget; // optional budget

  StudentProfile({
    required this.qualification,
    required this.isUpu,
    required this.interest,
    this.spmGrades,
    this.stpmGrades,
    this.preUniGrades,
    this.budget,
  });
}
