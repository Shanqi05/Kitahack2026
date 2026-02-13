import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (with error handling for web)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // On web, .env might not be available as an asset
    // This is expected behavior - Gemini API key should be provided via environment or config
    debugPrint('Warning: Could not load .env file: $e');
  }

  // Initialize Firebase
  await FirebaseService().initialize();

  runApp(const SleepNotFound404App());
}

class SleepNotFound404App extends StatelessWidget {
  const SleepNotFound404App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepNotFound404',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
