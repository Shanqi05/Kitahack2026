import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    }
  }

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<User?> signInAnonymously() async {
    final userCredential = await auth.signInAnonymously();
    return userCredential.user;
  }

  Future<void> saveChatMessage(String uid, String message, String role) async {
    await firestore.collection('chats').add({
      'uid': uid,
      'message': message,
      'role': role,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveAdmissionResult({
    required String qualification,
    required Map<String, String> grades,
    required List<String> interests,
    required List<String> topCourses,
    String? aiFeedback,
    double? budget, // NEW
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('admission_history')
          .add({
        'qualification': qualification,
        'grades': grades,
        'interests': interests,
        'top_courses': topCourses,
        'ai_feedback': aiFeedback ?? "No AI feedback generated.",
        'budget': budget, // NEW
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Result saved to history successfully!");
    } catch (e) {
      print("❌ Failed to save history: $e");
    }
  }
}