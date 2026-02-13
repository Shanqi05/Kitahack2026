import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseName;
  final String universityName;
  final double fee;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.courseName,
    required this.universityName,
    required this.fee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(
          courseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(universityName),
        trailing: Text("RM ${fee.toStringAsFixed(2)}"),
      ),
    );
  }
}
