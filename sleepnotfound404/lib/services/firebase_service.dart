import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

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

  // Example: Sign in anonymously
  Future<User?> signInAnonymously() async {
    final userCredential = await auth.signInAnonymously();
    return userCredential.user;
  }

  // Example: Save message to Firestore
  Future<void> saveChatMessage(String uid, String message, String role) async {
    await firestore.collection('chats').add({
      'uid': uid,
      'message': message,
      'role': role,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
