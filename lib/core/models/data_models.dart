// lib/core/models/data_models.dart

class ProfileData {
  final String name;
  final String identityNumber;
  final String email;
  final String phone;
  final String academicStatus;
  final String state;
  final String ethnicity;
  final String ethnicitySubgroup;
  final bool isFirstGen;
  final bool isOku;
  final List<String> specialConsiderations;

  ProfileData({
    this.name = '',
    this.identityNumber = '',
    this.email = '',
    this.phone = '',
    this.academicStatus = '',
    this.state = '',
    this.ethnicity = '',
    this.ethnicitySubgroup = '',
    this.isFirstGen = false,
    this.isOku = false,
    this.specialConsiderations = const [],
  });

  ProfileData copyWith({
    String? name,
    String? identityNumber,
    String? email,
    String? phone,
    String? academicStatus,
    String? state,
    String? ethnicity,
    String? ethnicitySubgroup,
    bool? isFirstGen,
    bool? isOku,
    List<String>? specialConsiderations,
  }) {
    return ProfileData(
      name: name ?? this.name,
      identityNumber: identityNumber ?? this.identityNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      academicStatus: academicStatus ?? this.academicStatus,
      state: state ?? this.state,
      ethnicity: ethnicity ?? this.ethnicity,
      ethnicitySubgroup: ethnicitySubgroup ?? this.ethnicitySubgroup,
      isFirstGen: isFirstGen ?? this.isFirstGen,
      isOku: isOku ?? this.isOku,
      specialConsiderations:
          specialConsiderations ?? this.specialConsiderations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'identityNumber': identityNumber,
      'email': email,
      'phone': phone,
      'academicStatus': academicStatus,
      'state': state,
      'ethnicity': ethnicity,
      'ethnicitySubgroup': ethnicitySubgroup,
      'isFirstGen': isFirstGen,
      'isOku': isOku,
      'specialConsiderations': specialConsiderations,
    };
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      academicStatus: json['academicStatus'] ?? '',
      state: json['state'] ?? '',
      ethnicity: json['ethnicity'] ?? '',
      ethnicitySubgroup: json['ethnicitySubgroup'] ?? '',
      isFirstGen: json['isFirstGen'] ?? false,
      isOku: json['isOku'] ?? false,
      specialConsiderations:
          (json['specialConsiderations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class SPMSubject {
  final String name;
  final String grade;
  final bool isElective;

  SPMSubject({
    required this.name,
    required this.grade,
    this.isElective = false,
  });

  SPMSubject copyWith({String? name, String? grade, bool? isElective}) {
    return SPMSubject(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      isElective: isElective ?? this.isElective,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'grade': grade, 'isElective': isElective};
  }

  factory SPMSubject.fromJson(Map<String, dynamic> json) {
    return SPMSubject(
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      isElective: json['isElective'] ?? false,
    );
  }
}

class PreUResult {
  final String subject;
  final String grade;
  final double score;

  PreUResult({
    required this.subject,
    required this.grade,
    this.score = 0.0,
  });

  PreUResult copyWith({String? subject, String? grade, double? score}) {
    return PreUResult(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() {
    return {'subject': subject, 'grade': grade, 'score': score};
  }

  factory PreUResult.fromJson(Map<String, dynamic> json) {
    return PreUResult(
      subject: json['subject'] ?? '',
      grade: json['grade'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AcademicData {
  final bool hasSpm;
  final List<SPMSubject> spmResults;
  final String qualificationType; // e.g. SPM Graduate, STPM, Matriculation, A-Level, UEC, IGCSE, Foundation, Asasi, Diploma
  final List<PreUResult> preUResults;
  final double cgpa;
  final int muetBand; // Legacy, kept for backward compatibility if needed, or repurposed
  final String englishTest; // 'MUET', 'IELTS', 'TOEFL', etc.
  final String englishScore; // 'Band 5', '7.0', etc.
  final String institutionName; // For Foundation / Asasi / Diploma
  final double coCurriculumScore; // For STPM/Matric/Diploma cocuriculum marks 0-10

  AcademicData({
    this.hasSpm = false,
    this.spmResults = const [],
    this.qualificationType = '',
    this.preUResults = const [],
    this.cgpa = 0.0,
    this.muetBand = 1,
    this.englishTest = '',
    this.englishScore = '',
    this.institutionName = '',
    this.coCurriculumScore = 0.0,
  });

  AcademicData copyWith({
    bool? hasSpm,
    List<SPMSubject>? spmResults,
    String? qualificationType,
    List<PreUResult>? preUResults,
    double? cgpa,
    int? muetBand,
    String? englishTest,
    String? englishScore,
    String? institutionName,
    double? coCurriculumScore,
  }) {
    return AcademicData(
      hasSpm: hasSpm ?? this.hasSpm,
      spmResults: spmResults ?? this.spmResults,
      qualificationType: qualificationType ?? this.qualificationType,
      preUResults: preUResults ?? this.preUResults,
      cgpa: cgpa ?? this.cgpa,
      muetBand: muetBand ?? this.muetBand,
      englishTest: englishTest ?? this.englishTest,
      englishScore: englishScore ?? this.englishScore,
      institutionName: institutionName ?? this.institutionName,
      coCurriculumScore: coCurriculumScore ?? this.coCurriculumScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasSpm': hasSpm,
      'spmResults': spmResults.map((e) => e.toJson()).toList(),
      'qualificationType': qualificationType,
      'preUResults': preUResults.map((e) => e.toJson()).toList(),
      'cgpa': cgpa,
      'muetBand': muetBand,
      'englishTest': englishTest,
      'englishScore': englishScore,
      'institutionName': institutionName,
      'coCurriculumScore': coCurriculumScore,
    };
  }

  factory AcademicData.fromJson(Map<String, dynamic> json) {
    return AcademicData(
      hasSpm: json['hasSpm'] ?? false,
      spmResults:
          (json['spmResults'] as List<dynamic>?)
              ?.map((e) => SPMSubject.fromJson(e))
              .toList() ??
          [],
      qualificationType:
          json['qualificationType'] ?? json['preUQualification'] ?? '',
      preUResults:
          (json['preUResults'] as List<dynamic>?)
              ?.map((e) => PreUResult.fromJson(e))
              .toList() ??
          [],
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
      muetBand: json['muetBand'] ?? 1,
      englishTest: json['englishTest'] ?? '',
      englishScore: json['englishScore'] ?? '',
      institutionName: json['institutionName'] ?? '',
      coCurriculumScore: (json['coCurriculumScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FinancialData {
  final double income;
  final int dependents;
  final String location; // Update: Added location

  FinancialData({
    this.income = 0.0,
    this.dependents = 0,
    this.location = 'Urban', // Default 'Urban'
  });

  FinancialData copyWith({double? income, int? dependents, String? location}) {
    return FinancialData(
      income: income ?? this.income,
      dependents: dependents ?? this.dependents,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {'income': income, 'dependents': dependents, 'location': location};
  }

  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      dependents: json['dependents'] as int? ?? 0,
      location: json['location'] as String? ?? 'Urban',
    );
  }
}

class PreferencesData {
  final double pajskScore;
  final List<String> interests;
  final List<String> leadership; // Update: Added leadership
  final List<String> achievements;
  final List<CompetitionEntry> competitions;
  final double cocurriculumScore; // For non-SPM paths (STPM/Matric/Diploma)
  final String topInterest; // Helper for Step 5

  PreferencesData({
    this.pajskScore = 0.0,
    this.interests = const [],
    this.leadership = const [],
    this.achievements = const [],
    this.competitions = const [],
    this.cocurriculumScore = 0.0,
    this.topInterest = '',
  });

  PreferencesData copyWith({
    double? pajskScore,
    List<String>? interests,
    List<String>? leadership,
    List<String>? achievements,
    List<CompetitionEntry>? competitions,
    double? cocurriculumScore,
    String? topInterest,
  }) {
    return PreferencesData(
      pajskScore: pajskScore ?? this.pajskScore,
      interests: interests ?? this.interests,
      leadership: leadership ?? this.leadership,
      achievements: achievements ?? this.achievements,
      competitions: competitions ?? this.competitions,
      cocurriculumScore: cocurriculumScore ?? this.cocurriculumScore,
      topInterest: topInterest ?? this.topInterest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pajskScore': pajskScore,
      'interests': interests,
      'leadership': leadership,
      'achievements': achievements,
      'competitions': competitions.map((e) => e.toJson()).toList(),
      'cocurriculumScore': cocurriculumScore,
      'topInterest': topInterest,
    };
  }

  factory PreferencesData.fromJson(Map<String, dynamic> json) {
    return PreferencesData(
      pajskScore: (json['pajskScore'] as num?)?.toDouble() ?? 0.0,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      leadership:
          (json['leadership'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      competitions:
          (json['competitions'] as List<dynamic>?)
              ?.map((e) => CompetitionEntry.fromJson(e))
              .toList() ??
          [],
      cocurriculumScore: (json['cocurriculumScore'] as num?)?.toDouble() ?? 0.0,
      topInterest: json['topInterest'] ?? '',
    );
  }
}

class CompetitionEntry {
  final String name;
  final String result;

  CompetitionEntry({required this.name, required this.result});

  CompetitionEntry copyWith({String? name, String? result}) {
    return CompetitionEntry(
      name: name ?? this.name,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'result': result};
  }

  factory CompetitionEntry.fromJson(Map<String, dynamic> json) {
    return CompetitionEntry(
      name: json['name'] ?? '',
      result: json['result'] ?? '',
    );
  }
}
