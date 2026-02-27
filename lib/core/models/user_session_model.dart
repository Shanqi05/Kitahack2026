// lib/core/models/user_session_model.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_models.dart';

/// Manages the global state of the user session and wizard progress.
class UserSessionModel extends ChangeNotifier {
  // Properties
  String _uid = '';
  ProfileData _profile = ProfileData();
  AcademicData _academic = AcademicData();
  FinancialData _financial = FinancialData();
  PreferencesData _preferences = PreferencesData();
  int _currentStep = 0; // Tracks Wizard progress (0 to 4)

  // Getters
  String get uid => _uid;
  ProfileData get profile => _profile;
  AcademicData get academic => _academic;
  FinancialData get financial => _financial;
  PreferencesData get preferences => _preferences;
  int get currentStep => _currentStep;

  // Convenience Getters for Step 5
  String get fullName => _profile.name;
  String get state => _profile.state;
  String get ethnicity => _profile.ethnicity;
  String get currentStatus =>
      _academic.qualificationType.isNotEmpty
          ? _academic.qualificationType
          : _profile.academicStatus;
  bool get hasSpm => _academic.hasSpm;
  double? get cgpa => _academic.cgpa > 0 ? _academic.cgpa : null;
  double get householdIncome => _financial.income;
  int get dependents => _financial.dependents;
  double get pajskScore => _preferences.pajskScore;
  String get topInterest => _preferences.topInterest.isNotEmpty
      ? _preferences.topInterest
      : (_preferences.interests.isNotEmpty
            ? _preferences.interests.first
            : 'None');

  String get incomeBracket {
    if (_financial.income < 4850) {
      return 'B40';
    } else if (_financial.income <= 10960) {
      return 'M40';
    } else {
      return 'T20';
    }
  }

  // Methods

  /// Updates the profile data and notifies listeners.
  void updateProfile(ProfileData data) {
    _profile = data;
    notifyListeners();
  }

  /// Updates the academic data and notifies listeners.
  void updateAcademic(AcademicData data) {
    _academic = data;
    notifyListeners();
  }

  /// Helper to update academic fields individually
  void updateAcademicFields({
    bool? hasSpm,
    String? status,
    double? cgpa,
    String? qualificationType,
  }) {
    // Keep qualification/status in both profile and academic for consistency.
    final resolvedStatus = status ?? qualificationType;
    if (resolvedStatus != null) {
      _profile = _profile.copyWith(academicStatus: resolvedStatus);
    }

    _academic = _academic.copyWith(
      hasSpm: hasSpm,
      cgpa: cgpa,
      qualificationType: qualificationType ?? _academic.qualificationType,
    );
    notifyListeners();
  }

  /// Updates the financial data and notifies listeners.
  void updateFinancial({double? income, int? dependents, String? location}) {
    _financial = _financial.copyWith(
      income: income,
      dependents: dependents,
      location: location,
    );
    notifyListeners();
  }

  void updateFinancialData(FinancialData data) {
    _financial = data;
    notifyListeners();
  }

  /// Updates the preferences data and notifies listeners.
  void updatePreferences(PreferencesData data) {
    _preferences = data;
    notifyListeners();
  }

  void updateTalent({double? pajskScore, String? topInterest}) {
    _preferences = _preferences.copyWith(
      pajskScore: pajskScore,
      topInterest: topInterest,
    );
    notifyListeners();
  }

  /// Advances to the next step in the wizard if not at the end.
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Returns to the previous step in the wizard if not at the start.
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Jumps to a specific step in the wizard.
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Calculates the merit score.
  /// Formula: (academic.higherEdu.cgpa / 4.0 * 90) + (preferences.pajsk)
  double calculateMeritScore() {
    double academicScore = 0.0;

    // Check if higherEdu is present to prevent null access
    // We are using flat structure for academic data now (cgpa directly on member)
    if (_academic.cgpa > 0) {
      academicScore = (_academic.cgpa / 4.0) * 90;
    } else {
      // Fallback logic if no CGPA? Maybe use SPM grades if we had logic for that
      // For now, default to 0
    }

    return academicScore + _preferences.pajskScore;
  }

  /// Aggregates all data into a final JSON format for export or processing.
  Map<String, dynamic> exportJson() {
    return {
      'profile': _profile.toJson(),
      'academic': _academic.toJson(),
      'financial': _financial.toJson(),
      'preferences': _preferences.toJson(),
      'meritScore': calculateMeritScore(),
      'currentStep': _currentStep,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Saves the current user profile to Firebase Firestore.
  Future<void> saveUserProfileToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print("User not logged in. Skipping Firestore save (Guest Mode).");
      }
      throw Exception("User not logged in");
    }

    try {
      final data = exportJson();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print("User profile saved to Firestore: users/${user.uid}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving profile to Firestore: $e");
      }
      rethrow;
    }
  }

  /// Fetches the user profile from Firebase Firestore.
  /// Returns existing data or null if not found.
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Populate model with fetched data
        if (data['profile'] != null) {
          _profile = ProfileData.fromJson(data['profile']);
        }
        if (data['academic'] != null) {
          _academic = AcademicData.fromJson(data['academic']);
        }
        if (data['financial'] != null) {
          _financial = FinancialData.fromJson(data['financial']);
        }
        if (data['preferences'] != null) {
          _preferences = PreferencesData.fromJson(data['preferences']);
        }
        if (data['currentStep'] != null) {
          _currentStep = data['currentStep'] as int;
        }

        notifyListeners();
        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
    }
    return null;
  }
}
