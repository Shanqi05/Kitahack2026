import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/firebase_service.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (skip on web)
  try {
    // Only attempt to load .env on native platforms
    if (!identical(0, 0.0)) {
      // This is always false, but keeps web-safe structure
      await dotenv.load(fileName: ".env");
    }
  } catch (e) {
    debugPrint('Info: .env file not loaded (expected on web): $e');
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
      home: const LoginScreen(),
    );
  }
}
