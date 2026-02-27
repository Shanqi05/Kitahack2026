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
    // Handle field as either string or array
    String field;
    final fieldData = json['field'];
    if (fieldData is List) {
      // If it's an array, take the first element
      field = (fieldData as List).isNotEmpty
          ? fieldData[0].toString()
          : 'General';
    } else {
      // If it's a string, use it directly
      field = fieldData.toString();
    }

    return CourseModel(
      id: json['id'],
      name: json['name'],
      field: field,
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
