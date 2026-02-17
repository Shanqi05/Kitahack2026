class StudentProfile {
  final String qualification; // SPM, STPM, Matrikulasi, Asasi, Diploma
  final bool isUpu; // true if applying via UPU
  final List<String> interest; // IT, Engineering, etc.
  final Map<String, String>? spmGrades; // subject: grade
  final Map<String, String>? stpmGrades; // optional
  final Map<String, String>? preUniGrades; // Matrikulasi / Asasi / Diploma
  final double? budget; // optional budget
  final String?
  stream; // Science, Commerce, Arts (for STPM/Asasi/Matriculation)
  final String? diplomaField; // Field of diploma (for mapping to degree)

  // Merit calculation related fields
  final List<int>? spmCompulsoryMarks; // For SPM UPU merit calculation
  final List<int>? spmElectiveMarks; // For SPM UPU merit calculation
  final List<int>? spmAdditionalMarks; // For SPM UPU merit calculation
  final double? cgpa; // For STPM/Asasi/Matrikulasi/Diploma merit calculation
  final double coCurricularMark; // Co-curricular points (0-10), default 0
  final double? calculatedMerit; // Calculated merit score (0-100)

  StudentProfile({
    required this.qualification,
    required this.isUpu,
    required this.interest,
    this.spmGrades,
    this.stpmGrades,
    this.preUniGrades,
    this.budget,
    this.stream,
    this.diplomaField,
    this.spmCompulsoryMarks,
    this.spmElectiveMarks,
    this.spmAdditionalMarks,
    this.cgpa,
    this.coCurricularMark = 0.0,
    this.calculatedMerit,
  });
}
