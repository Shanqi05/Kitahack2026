import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final double? budget;

  const ResultScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.budget,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: integrate AdmissionEngine to show real recommendations
    return Scaffold(
      appBar: AppBar(title: const Text("Your Recommendations")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Here will be the top 3 courses based on your profile", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Then universities for each course, filtered by budget and UPU/private", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
