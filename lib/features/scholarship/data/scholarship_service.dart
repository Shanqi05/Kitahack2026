import 'dart:convert';
import 'package:flutter/services.dart';

class ScholarshipModel {
  final String id;
  final String name;
  final String provider;
  final String amount;
  final String deadline;
  final String criteria;
  final String category;
  final String link;

  ScholarshipModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.amount,
    required this.deadline,
    required this.criteria,
    required this.category,
    required this.link,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['id'],
      name: json['name'],
      provider: json['provider'],
      amount: json['amount'],
      deadline: json['deadline'],
      criteria: json['criteria'],
      category: json['category'],
      link: json['link'],
    );
  }
}

class ScholarshipService {
  Future<List<ScholarshipModel>> loadScholarships() async {
    try {
      final String response = await rootBundle.loadString('assets/data/scholarships.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => ScholarshipModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading scholarships: $e");
      return [];
    }
  }
}