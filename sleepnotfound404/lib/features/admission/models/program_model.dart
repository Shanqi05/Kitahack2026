class ProgramModel {
  final String universityId;
  final String courseId;
  final String level;
  final List<String> entryMode; // ["UPU"] or ["Private"]
  final int? minMerit; // null for private
  final double annualFee;
  final String interestField;

  ProgramModel({
    required this.universityId,
    required this.courseId,
    required this.level,
    required this.entryMode,
    required this.minMerit,
    required this.annualFee,
    required this.interestField,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      universityId: json['university_id'],
      courseId: json['course_id'],
      level: json['level'],
      entryMode: List<String>.from(json['entry_mode']),
      minMerit: json['min_merit'],
      annualFee: (json['annual_fee'] as num).toDouble(),
      interestField: json['interest_field'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university_id': universityId,
      'course_id': courseId,
      'level': level,
      'entry_mode': entryMode,
      'min_merit': minMerit,
      'annual_fee': annualFee,
      'interest_field': interestField,
    };
  }
}
