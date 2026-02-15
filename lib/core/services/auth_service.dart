import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web specific handling
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );
        return userCredential.user;
      } else {
        // Mobile handling
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        return userCredential.user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  /// Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in with email: $e');
      return null;
    }
  }

  /// Sign up with Email and Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Login as Guest
  Future<bool> loginAsGuest() async {
    try {
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      print('Error signing in as guest: $e');
      return false;
    }
  }
}
