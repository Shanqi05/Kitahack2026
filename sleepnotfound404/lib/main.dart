import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart'; // Ensure you ran 'flutterfire configure'
import 'package:sleepnotfound404/features/career_analysis/upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env and Firebase
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SleepNotFoundApp());
}

class SleepNotFoundApp extends StatelessWidget {
  const SleepNotFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sleep Not Found 404',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF673AB7), // Deep Purple (USM style)
      ),
      home: const ResumeUploadScreen(),
    );
  }
}