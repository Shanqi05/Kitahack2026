class ProgramModel {
  final String universityId;
  final String courseId;
  final String level;
  final List<String> entryMode;
  final double? minMerit; // ✅ 变成 double，兼容 83.91 这种分数
  final double annualFee;
  final String interestField;
  final double? muetBand; // ✅ 变成 double，兼容 2.5 这种 Band

  ProgramModel({
    required this.universityId,
    required this.courseId,
    required this.level,
    required this.entryMode,
    required this.minMerit,
    required this.annualFee,
    required this.interestField,
    this.muetBand,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    String interestField;
    final field = json['interest_field'];
    if (field is List) {
      interestField = field.isNotEmpty ? field[0].toString() : 'General';
    } else {
      interestField = field.toString();
    }

    return ProgramModel(
      universityId: json['university_id'],
      courseId: json['course_id'],
      level: json['level'],
      entryMode: List<String>.from(json['entry_mode']),
      minMerit: json['min_merit'] != null ? (json['min_merit'] as num).toDouble() : null,
      annualFee: json['annual_fee'] != null ? (json['annual_fee'] as num).toDouble() : 0.0,
      interestField: interestField,
      muetBand: json['muet_band'] != null ? (json['muet_band'] as num).toDouble() : null,
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
      'muet_band': muetBand,
    };
  }
}