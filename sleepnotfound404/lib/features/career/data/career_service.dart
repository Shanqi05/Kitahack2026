import 'dart:convert';
import 'package:flutter/services.dart';

class CareerModel {
  final String id;
  final String title;
  final String category;
  final String salaryRange;
  final String demand;
  final String description;
  final List<String> skills;
  final String pathway;

  CareerModel({
    required this.id,
    required this.title,
    required this.category,
    required this.salaryRange,
    required this.demand,
    required this.description,
    required this.skills,
    required this.pathway,
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      salaryRange: json['salary_range'],
      demand: json['demand'],
      description: json['description'],
      skills: List<String>.from(json['skills']),
      pathway: json['pathway'],
    );
  }
}

class CareerService {
  // Load career data from local JSON
  Future<List<CareerModel>> loadCareers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/careers.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => CareerModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading careers: $e");
      return [];
    }
  }
}