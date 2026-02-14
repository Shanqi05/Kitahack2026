import 'dart:convert';
import 'package:flutter/services.dart';

class InsightModel {
  final String id;
  final String title;
  final String insight;
  final List<String> careers;
  final String advice;

  InsightModel({
    required this.id,
    required this.title,
    required this.insight,
    required this.careers,
    required this.advice,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'],
      title: json['title'],
      insight: json['insight'],
      careers: List<String>.from(json['careers']),
      advice: json['advice'],
    );
  }
}

class CareerInsightService {
  Future<List<InsightModel>> loadInsights() async {
    try {
      final String response = await rootBundle.loadString('assets/data/career_insights.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => InsightModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading insights: $e");
      return [];
    }
  }

  Future<List<InsightModel>> getMatchedInsights(List<String> userInterests) async {
    final allInsights = await loadInsights();
    return allInsights.where((insight) => userInterests.contains(insight.id)).toList();
  }
}