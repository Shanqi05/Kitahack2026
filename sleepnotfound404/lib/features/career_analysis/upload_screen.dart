import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add this
import 'package:sleepnotfound404/services/gemini_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  final GeminiService _gemini = GeminiService();
  String _aiResponse = "Ready to analyze your future! Upload a resume or type your skills.";
  bool _isLoading = false;

  // New function to pick a file!
  void _pickAndAnalyzeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result != null) {
      setState(() => _isLoading = true);
      
      // For now, we simulate reading the file text
      // In a full app, you'd use a PDF parser here
      String fileName = result.files.single.name;
      
      final aiAdvice = await _gemini.getCareerAdvice(
        "Analyze this student's profile from file: $fileName. They have strong leadership as a club president."
      );
      
      setState(() {
        _aiResponse = aiAdvice ?? "AI couldn't read the file.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Not Found 404"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_aiResponse, textAlign: TextAlign.center),
            ),
            if (_isLoading) const SpinKitWave(color: Colors.deepPurple, size: 50),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickAndAnalyzeFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Resume (PDF/TXT)"),
            ),
          ],
        ),
      ),
    );
  }
}