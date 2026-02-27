class UniversityModel {
  final String id;
  final String name;
  final String type; // Public or Private
  final String location;

  UniversityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
    };
  }
}
