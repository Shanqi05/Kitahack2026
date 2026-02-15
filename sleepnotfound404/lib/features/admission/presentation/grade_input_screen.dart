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
  final List<String> _selectedSubjects = [];
  double? _cgpa;
  String? _selectedStream; // Science, Commerce, Arts (for STPM/Asasi/Matriculation)

  // Define subjects based on qualification
  final Map<String, List<String>> _subjectsByQualification = {
    'SPM': ['Bahasa Melayu', 'English', 'Mathematics', 'History'],
    'STPM': ['Pengajian Am'],
    'Matriculation': ['Mathematics'],
    'Asasi': [],
    'Diploma': [],
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

  // Check if CGPA is required (all except SPM)
  bool get _requiresCGPA => widget.qualification != 'SPM';

  // Check if stream selection is required (STPM, Matriculation, Asasi)
  bool get _requiresStreamSelection =>
      ['STPM', 'Matriculation', 'Asasi'].contains(widget.qualification);


  @override
  void initState() {
    super.initState();
    final defaultSubjects = _subjectsByQualification[widget.qualification] ?? [];
    _selectedSubjects.addAll(defaultSubjects.take(5)); // Start with first 5 subjects
  }

  void _addSubject() {
    final TextEditingController subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your subject name:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  hintText: 'e.g., English, Physics, Chemistry',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    final subject = value.trim();
                    if (_selectedSubjects.contains(subject)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$subject is already added'),
                          backgroundColor: Colors.orange[700],
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _selectedSubjects.add(subject);
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final subject = subjectController.text.trim();
              if (subject.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a subject name'),
                    backgroundColor: Colors.red[700],
                  ),
                );
                return;
              }
              if (_selectedSubjects.contains(subject)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$subject is already added'),
                    backgroundColor: Colors.orange[700],
                  ),
                );
                return;
              }
              setState(() {
                _selectedSubjects.add(subject);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
            ),
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  void _removeSubject(String subject) {
    setState(() {
      _selectedSubjects.remove(subject);
      _grades.remove(subject);
    });
  }

  @override
  Widget build(BuildContext context) {
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

              // Display selected subjects with grades
              ..._selectedSubjects.map((subject) => Dismissible(
                key: ValueKey(subject),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.withOpacity(0.7),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _removeSubject(subject),
                child: GradeInputField(
                  subject: subject,
                  value: _grades[subject],
                  gradeOptions: _gradeOptions,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) _grades[subject] = value;
                    });
                  },
                ),
              )),

              // Add button for more subjects
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: _addSubject,
                  icon: const Icon(Icons.add),
                  label: const Text('Add More Subject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                    foregroundColor: const Color(0xFF673AB7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF673AB7), width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stream Selection (for STPM, Matriculation, Asasi)
              if (_requiresStreamSelection) ...[
                const Text(
                  'Select Your Academic Stream',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStream,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Science',
                      child: Text('Science'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Commerce',
                      child: Text('Commerce/Account'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Arts',
                      child: Text('Arts'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStream = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Academic Stream',
                    hintText: 'Select your stream',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (_requiresStreamSelection && (value == null || value.isEmpty)) {
                      return 'Please select your academic stream';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // CGPA Field (only for non-SPM qualifications)
              if (_requiresCGPA) ...[
                const Text(
                  'Enter Your CGPA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'CGPA (e.g., 3.5)',
                    hintText: '0.0 - 4.0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CGPA';
                    }
                    final cgpa = double.tryParse(value);
                    if (cgpa == null || cgpa < 0 || cgpa > 4.0) {
                      return 'Please enter a valid CGPA (0.0 - 4.0)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _cgpa = double.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 30),
              ],

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
      // Validate that at least one grade is entered
      if (_grades.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one grade'),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      // For non-SPM, validate CGPA is entered
      if (_requiresCGPA && (_cgpa == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your CGPA'),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      // Validate stream is selected if required
      if (_requiresStreamSelection && (_selectedStream == null || _selectedStream!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your academic stream'),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }

      // Add CGPA to grades map if exists
      Map<String, String> finalGrades = Map.from(_grades);
      if (_cgpa != null) {
        finalGrades['CGPA'] = _cgpa.toString();
      }

      // Navigate to InterestSelectionScreen passing the collected grades and stream
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterestSelectionScreen(
            qualification: widget.qualification,
            upu: widget.upu,
            grades: finalGrades,
            resumeFile: widget.resumeFile,
            stream: _selectedStream,
          ),
        ),
      );
    }
  }
}