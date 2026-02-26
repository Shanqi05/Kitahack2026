import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Added Provider

import 'core/theme/app_theme.dart';
import 'core/models/user_session_model.dart'; // Added User Session
import 'services/firebase_service.dart';

// The new Front Door!
import 'features/dashboard/screens/main_dashboard_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (skip on web)
  try {
    if (!identical(0, 0.0)) {
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
    // We MUST wrap the app in a Provider so Warren's dashboard can read the user data!
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSessionModel()),
      ],
      child: MaterialApp(
        title: 'SleepNotFound404',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Bypass the old HomeScreen and load the new Dashboard Shell
        home: const MainDashboardShell(),
      ),
    );
  }
}