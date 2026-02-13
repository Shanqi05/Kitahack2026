class CourseModel {
  final String id;
  final String name;
  final String field;
  final List<String> level;

  CourseModel({
    required this.id,
    required this.name,
    required this.field,
    required this.level,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      field: json['field'],
      level: List<String>.from(json['level']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field': field,
      'level': level,
    };
  }
}
