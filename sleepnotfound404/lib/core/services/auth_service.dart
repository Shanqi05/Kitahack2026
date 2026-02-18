import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Local guest mode flag
  bool _isGuestMode = false;

  /// Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is in guest mode
  bool get isGuestMode => _isGuestMode;

  /// Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print('Attempting login with email: $email');
      print('Password length: ${password.length}');

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful for user: ${result.user?.email}');
      _isGuestMode = false;
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      print('Full error: $e');
      rethrow;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Sign up with Email and Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      print('Attempting signup with email: $email');
      print('Password length: ${password.length}');

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Signup successful for user: ${result.user?.email}');
      _isGuestMode = false;
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
      print('Full error: $e');
      rethrow;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isGuestMode = false;
    await _auth.signOut();
  }

  /// Login as Guest (No Firebase required - local mode)
  Future<bool> loginAsGuest() async {
    try {
      print('Guest mode activated - no Firebase authentication required');
      _isGuestMode = true;
      return true;
    } catch (e) {
      print('Error setting guest mode: $e');
      return false;
    }
  }
}
