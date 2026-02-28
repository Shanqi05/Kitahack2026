import 'package:flutter/material.dart';

class GradeInputField extends StatelessWidget {
  final String subject;
  final String? value; // Currently selected grade
  final ValueChanged<String?> onChanged;
  final List<String> gradeOptions; // List of available grades (e.g., A+, A, A-)

  const GradeInputField({
    super.key,
    required this.subject,
    required this.value,
    required this.onChanged,
    required this.gradeOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: subject,
          labelStyle: TextStyle(color: Colors.grey[600]),
          // Default border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          // Border when enabled but not focused
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          // Border when focused (purple color)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        icon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFF673AB7)),
        // Map the grade strings to DropdownMenuItem widgets
        items: gradeOptions.map((String grade) {
          return DropdownMenuItem<String>(
            value: grade,
            child: Text(
              grade,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        // Validation logic
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a grade';
          }
          return null;
        },
      ),
    );
  }
}