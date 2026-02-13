import 'package:flutter_test/flutter_test.dart';
import 'package:sleepnotfound404/features/admission/data/admission_engine.dart';
import 'package:sleepnotfound404/features/admission/models/student_profile.dart';

void main() {
  group('AdmissionEngine', () {
    final engine = AdmissionEngine();

    test('Recommend courses for SPM non-UPU student', () {
      final profile = StudentProfile(
        qualification: 'SPM',
        isUpu: false,
        interest: ['IT', 'Engineering'],
      );

      final recommendations = engine.getRecommendations(profile);

      expect(recommendations.length, greaterThanOrEqualTo(1));

      for (var r in recommendations) {
        expect(
          ['Diploma', 'Foundation', 'A-Level'].contains(r.course.level.first),
          true,
        );
      }
    });

    test('Recommend courses for SPM UPU student', () {
      final profile = StudentProfile(
        qualification: 'SPM',
        isUpu: true,
        interest: ['Science'],
      );

      final recommendations = engine.getRecommendations(profile);

      expect(recommendations.length, greaterThanOrEqualTo(1));

      for (var r in recommendations) {
        expect(['Asasi', 'Diploma'].contains(r.course.level.first), true);
      }
    });

    test('Recommend courses for Matrikulasi student', () {
      final profile = StudentProfile(
        qualification: 'Matrikulasi',
        isUpu: false,
        interest: ['Engineering'],
      );

      final recommendations = engine.getRecommendations(profile);

      expect(recommendations.length, greaterThanOrEqualTo(1));
      for (var r in recommendations) {
        expect(['Degree'].contains(r.course.level.first), true);
      }
    });
  });
}
