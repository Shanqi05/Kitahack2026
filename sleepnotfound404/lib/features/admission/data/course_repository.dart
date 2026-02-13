import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course_model.dart';
import '../models/university_model.dart';
import '../models/program_model.dart';

class CourseRepository {
  List<CourseModel> courses = [];
  List<UniversityModel> universities = [];
  List<ProgramModel> programs = [];

  Future<void> loadData() async {
    final coursesJson = await rootBundle.loadString('assets/data/courses.json');
    final universitiesJson = await rootBundle.loadString('assets/data/universities.json');
    final programsJson = await rootBundle.loadString('assets/data/program_offerings.json');

    courses = (json.decode(coursesJson) as List)
        .map((e) => CourseModel.fromJson(e))
        .toList();

    universities = (json.decode(universitiesJson) as List)
        .map((e) => UniversityModel.fromJson(e))
        .toList();

    programs = (json.decode(programsJson) as List)
        .map((e) => ProgramModel.fromJson(e))
        .toList();
  }

  List<ProgramModel> getProgramsByInterest(List<String> interests, {bool? upu}) {
    return programs.where((p) {
      final matchesInterest = interests.contains(p.interestField);
      final matchesUpu = upu == null || (upu && p.entryMode.contains("UPU")) || (!upu && !p.entryMode.contains("UPU"));
      return matchesInterest && matchesUpu;
    }).toList();
  }
}
