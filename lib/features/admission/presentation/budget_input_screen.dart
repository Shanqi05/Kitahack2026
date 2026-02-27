import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Import ResultScreen to navigate there finally
import 'result_screen.dart';

class BudgetInputScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final Map<String, String> grades;
  final List<String> interests;
  final PlatformFile? resumeFile;
  final String?
  stream; // Science, Commerce, Arts (for STPM/Asasi/Matriculation)
  final String? diplomaField; // For Foundation and Diploma

  const BudgetInputScreen({
    super.key,
    required this.qualification,
    required this.upu,
    required this.grades,
    required this.interests,
    this.resumeFile,
    this.stream,
    this.diplomaField,
  });

  @override
  State<BudgetInputScreen> createState() => _BudgetInputScreenState();
}

class _BudgetInputScreenState extends State<BudgetInputScreen> {
  // Default budget value
  double _budget = 20000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expected Budget"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is your budget?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF673AB7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred annual tuition fee range',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 50),

            // --- Budget Slider UI ---
            Center(
              child: Column(
                children: [
                  Text(
                    "RM ${_budget.toStringAsFixed(0)} / year",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _budget,
                    min: 5000,
                    max: 100000,
                    divisions: 19, // Steps of 5000
                    activeColor: const Color(0xFF673AB7),
                    inactiveColor: const Color(0xFF673AB7).withOpacity(0.2),
                    label: "RM ${_budget.round()}",
                    onChanged: (value) {
                      setState(() {
                        _budget = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("RM 5k", style: TextStyle(color: Colors.grey)),
                      Text("RM 100k+", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Navigate to Results
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        qualification: widget.qualification,
                        upu: widget.upu,
                        grades: widget.grades,
                        interests: widget.interests,
                        budget: _budget,
                        resumeFile: widget.resumeFile,
                        stream: widget.stream,
                        diplomaField: widget.diplomaField,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'View Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
