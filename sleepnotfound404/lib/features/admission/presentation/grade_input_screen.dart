import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../widgets/grade_input_field.dart';
import '../../../../widgets/custom_button.dart';
import 'interest_selection_screen.dart';

class GradeInputScreen extends StatefulWidget {
  final String qualification;
  final bool upu;
  final PlatformFile? resumeFile;

  const GradeInputScreen({
    super.key,
    required this.qualification,
    required this.upu,
    this.resumeFile,
  });

  @override
  State<GradeInputScreen> createState() => _GradeInputScreenState();
}

class _GradeInputScreenState extends State<GradeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _grades = {};

  // Define subjects based on qualification
  final Map<String, List<String>> _subjectsByQualification = {
    'SPM': ['Bahasa Melayu', 'English', 'Mathematics', 'History', 'Science', 'Add Maths', 'Physics', 'Chemistry', 'Biology'],
    'STPM': ['Pengajian Am', 'Mathematics T', 'Physics', 'Chemistry', 'Biology'],
    'Matriculation': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science'],
    'UEC': ['Chinese', 'English', 'Mathematics', 'Advanced Maths', 'Physics', 'Chemistry'],
    'IGCSE': ['English', 'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Business Studies'],
  };

  // Get grade options based on qualification
  List<String> get _gradeOptions {
    if (widget.qualification == 'SPM' || widget.qualification == 'IGCSE') {
      return ['A+', 'A', 'A-', 'B+', 'B', 'C+', 'C', 'D', 'E', 'G'];
    } else if (widget.qualification == 'STPM' || widget.qualification == 'Matriculation') {
      return ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F'];
    } else if (widget.qualification == 'UEC') {
      return ['A1', 'A2', 'B3', 'B4', 'B5', 'B6', 'C7', 'C8', 'F9'];
    }
    return ['A', 'B', 'C', 'D', 'F'];
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _subjectsByQualification[widget.qualification] ??
        ['Subject 1', 'Subject 2', 'Subject 3', 'Subject 4', 'Subject 5'];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.qualification} Grades"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Enter Your Results',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your grade for each subject',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Generate dropdowns for each subject
              ...subjects.map((subject) => GradeInputField(
                subject: subject,
                value: _grades[subject],
                gradeOptions: _gradeOptions,
                onChanged: (value) {
                  setState(() {
                    if (value != null) _grades[subject] = value;
                  });
                },
              )),

              const SizedBox(height: 30),
              CustomButton(
                text: "Next: Select Interests",
                onPressed: _submitGrades,
                isLoading: false,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _submitGrades() {
    if (_formKey.currentState!.validate()) {
      // Navigate to InterestSelectionScreen passing the collected grades
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterestSelectionScreen(
            qualification: widget.qualification,
            upu: widget.upu,
            grades: _grades, // Pass grades forward
            resumeFile: widget.resumeFile,
          ),
        ),
      );
    }
  }
}