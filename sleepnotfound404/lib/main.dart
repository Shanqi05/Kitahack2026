import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
