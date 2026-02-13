import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'dart:async';

class LoadingAnalysisScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final double? budget;

  const LoadingAnalysisScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.budget,
  });

  @override
  State<LoadingAnalysisScreen> createState() => _LoadingAnalysisScreenState();
}

class _LoadingAnalysisScreenState extends State<LoadingAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate AI analysis
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            qualification: widget.qualification,
            upu: widget.upu,
            grades: widget.grades,
            interests: widget.interests,
            budget: widget.budget,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Analyzing your profile with AI...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
