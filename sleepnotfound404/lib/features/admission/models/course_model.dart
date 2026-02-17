class CourseModel {
  final String id;
  final String name;
  final String field;
  final List<String> level;
  final double? minMeritRequired; // Minimum merit score required (0-100)

  CourseModel({
    required this.id,
    required this.name,
    required this.field,
    required this.level,
    this.minMeritRequired,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      field: json['field'],
      level: List<String>.from(json['level']),
      minMeritRequired: json['minMeritRequired'] != null
          ? (json['minMeritRequired'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field': field,
      'level': level,
      'minMeritRequired': minMeritRequired,
    };
  }
}
