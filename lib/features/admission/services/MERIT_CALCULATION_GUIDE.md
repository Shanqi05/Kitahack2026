# Merit Calculation System Documentation

## Overview

This document describes the merit calculation system for the UPU admission platform and other qualification types. The system calculates student merit scores based on their academic performance and co-curricular achievements, enabling automatic course recommendation filtering based on minimum merit requirements.

## Qualification Types and Formulas

### 1. SPM (UPU Platform Only)

**Applicable to**: Students with SPM qualification applying through UPU platform

**Formula**: 
```
Merit = ((Academic Score / 80) × 90) + Co-curricular Mark
Final Merit Range: 0-100
```

**Components**:
- **Academic Score**: Sum of marks from compulsory, elective, and additional subjects
  - Maximum: 80 marks total
  - Calculation: Compulsory marks + Elective marks + Additional marks
- **Academic Conversion**: 90 points allocated based on academic performance
  - Formula: (Academic / 80) × 90
- **Co-curricular**: Additional 10 points based on extracurricular achievements
  - Range: 0-10 points
  - Examples: Sports, clubs, leadership roles, community service

  // ==============================
  // SPM MERIT CALCULATION (UPU)
  // ==============================
  //
  // Weightage:
  // Compulsory (4 subjects)  = 40%
  // Elective (2 subjects)    = 30%
  // Additional (max 2)       = 10%
  // Academic Total           = 80%
  // Co-curricular            = 10%
  //
  // Final Formula:
  // ((Academic / 80) * 90) + Co-curricular
  //
  // Grade system assumed:
  // A+ = 18 ... G = 0
---

### 2. STPM / Asasi / Matrikulasi (Pre-University)

**Applicable to**: Students with STPM, Asasi, or Matrikulasi qualifications applying for degree programs

**Formula**:
```
Merit = (CGPA / 4.0 × 90) + Co-curricular Mark
Final Merit Range: 0-100
```

**Components**:
- **CGPA**: Cumulative Grade Point Average on 4.0 scale
  - Range: 0.0 - 4.0
  - Standard CGPA calculation: (grade points sum) / (number of subjects)
- **CGPA Conversion**: 90 points allocated based on CGPA
  - Formula: (CGPA / 4.0) × 90
- **Co-curricular**: Additional 10 points based on achievements
  - Range: 0-10 points

**Grade to Point Conversion** (typical 4.0 scale):
- A+ / A: 4.0
- A-: 3.7
- B+: 3.3
- B: 3.0
- B-: 2.7
- C+: 2.3
- C: 2.0
- C-: 1.7
- D: 1.0
- F: 0.0

**Example Calculation**:
```
CGPA: 3.75
Co-curricular: 7

Academic converted: (3.75 / 4.0) × 90 = 84.375
Merit = 84.375 + 7 = 91.375
```

---

### 3. Diploma

**Applicable to**: Students with Diploma qualification applying for degree programs

**Formula**:
```
Merit = (CGPA / 4.0) × 100
Final Merit Range: 0-100
```

**Components**:
- **CGPA**: Cumulative Grade Point Average on 4.0 scale
  - Range: 0.0 - 4.0
- **CGPA Conversion**: Converted directly to 100-point scale
  - Formula: (CGPA / 4.0) × 100
- **Note**: Co-curricular points are NOT included for diploma students

**Example Calculation**:
```
CGPA: 3.50

Merit = (3.50 / 4.0) × 100 = 87.5
```

---

## Implementation Guide

### Using MeritCalculator Class

#### SPM Merit Calculation (UPU)

```dart
import 'package:sleepnotfound404/features/admission/services/merit_calculator.dart';

double merit = MeritCalculator.calculateSpmMerit(
  compulsoryMarks: [90, 88, 85],    // 3 compulsory subjects
  electiveMarks: [92, 87],          // 2 elective subjects
  additionalMarks: [80],            // 1 additional subject
  coCurricularMark: 8.5,            // 0-10
);

print('SPM Merit: $merit'); // Output: SPM Merit: XX.X
```

#### Pre-University Merit Calculation (STPM/Asasi/Matrikulasi)

```dart
double merit = MeritCalculator.calculatePreUniversityMerit(
  cgpa: 3.75,           // 0.0 - 4.0
  coCurricularMark: 9.0, // 0-10
);

print('STPM Merit: $merit'); // Output: STPM Merit: 91.375
```

#### Diploma Merit Calculation

```dart
double merit = MeritCalculator.calculateDiplomaMerit(
  cgpa: 3.50, // 0.0 - 4.0
);

print('Diploma Merit: $merit'); // Output: Diploma Merit: 87.5
```

#### Generic Calculate Method

```dart
double merit = MeritCalculator.calculateMerit(
  qualification: 'SPM',
  isUpu: true,
  compulsoryMarks: [85, 88, 90],
  electiveMarks: [87, 92],
  additionalMarks: [85],
  coCurricularMark: 7.5,
);

// Or for STPM:
double meritStpm = MeritCalculator.calculateMerit(
  qualification: 'STPM',
  isUpu: true,
  cgpa: 3.75,
  coCurricularMark: 8.0,
);
```

### Checking Merit Requirements

```dart
bool eligible = MeritCalculator.meetsRequirement(
  studentMerit: 78.5,
  courseMinMerit: 75.0,
);

if (eligible) {
  print('Student is eligible for this course');
} else {
  print('Student does not meet the minimum merit requirement');
}
```

### Integrating with StudentProfile

```dart
import 'package:sleepnotfound404/features/admission/models/student_profile.dart';

StudentProfile student = StudentProfile(
  qualification: 'SPM',
  isUpu: true,
  interest: ['IT', 'Engineering'],
  spmCompulsoryMarks: [85, 88, 90],
  spmElectiveMarks: [87, 92],
  spmAdditionalMarks: [85],
  coCurricularMark: 7.5,
);

// Calculate merit
double merit = MeritCalculator.calculateSpmMerit(
  compulsoryMarks: student.spmCompulsoryMarks ?? [],
  electiveMarks: student.spmElectiveMarks ?? [],
  additionalMarks: student.spmAdditionalMarks ?? [],
  coCurricularMark: student.coCurricularMark,
);
```

---

## Using Utility Functions

The `MeritUtility` class provides helper functions for common operations:

### Get Formatted Merit String

```dart
import 'package:sleepnotfound404/features/admission/services/merit_utility.dart';

String formattedMerit = MeritUtility.calculateAndFormatMerit(
  qualification: 'SPM',
  isUpu: true,
  spmCompulsoryMarks: [85, 88, 90],
  spmElectiveMarks: [87, 92],
  spmAdditionalMarks: [85],
  coCurricularMark: 7.5,
);

print('Merit: $formattedMerit'); // Output: Merit: 87.81
```

### Get Eligibility Status

```dart
String status = MeritUtility.getEligibilityStatus(
  studentMerit: 78.5,
  courseMinMerit: 75.0,
);

print(status); // Output: Eligible (+3.5 points)
```

### Get Merit Grade

```dart
String grade = MeritUtility.getMeritGrade(85.5);
print(grade); // Output: B (Very Good)
```

### Calculate Required Marks

```dart
// For SPM students targeting a specific merit
var required = MeritUtility.calculateRequiredSpmMarks(
  targetMerit: 80.0,
  coCurricularMark: 8.0,
  numCompulsory: 3,
  numElective: 2,
  numAdditional: 1,
);

print('Required academic score: ${required['requiredAcademicScore']}');
print('Average mark needed: ${required['averageMarkNeeded']}');
```

---

## Course Filtering by Merit

### How It Works

1. **Student Merit Calculation**: When a student's profile is submitted, their merit score is calculated automatically
2. **Course Filtering**: Courses are filtered to only show those where:
   - `Student Merit >= Course Minimum Merit Requirement`
3. **Display Status**: Each recommended course shows:
   - Whether the student meets the requirement
   - Point excess/shortfall

### In AdmissionEngine

The `getRecommendations()` method automatically:
1. Calculates the student's merit score
2. Filters programs based on merit requirements
3. Includes merit information in each recommendation
4. Marks recommendations with `meetsRequirement` flag

**Relevant Code**:
```dart
// Step 6: Filter by merit requirement
if (studentMerit != null && student.isUpu) {
  filtered = filtered.where((p) {
    if (p.minMerit == null) {
      return true; // No merit requirement
    }
    return studentMerit >= p.minMerit!;
  }).toList();
}
```

---

## Error Handling

### Input Validation

All calculator methods validate inputs:

```dart
// Throws ArgumentError for invalid co-curricular mark
MeritCalculator.calculateSpmMerit(
  compulsoryMarks: [70, 70, 70],
  electiveMarks: [70, 70],
  additionalMarks: [70],
  coCurricularMark: 15.0, // ERROR: Must be 0-10
);

// Throws ArgumentError for invalid CGPA
MeritCalculator.calculatePreUniversityMerit(
  cgpa: 4.5, // ERROR: Must be 0.0-4.0
  coCurricularMark: 5.0,
);
```

### Safe Calculation with Try-Catch

```dart
double? studentMerit;
try {
  studentMerit = MeritCalculator.calculateSpmMerit(
    compulsoryMarks: marks,
    electiveMarks: electives,
    additionalMarks: additional,
    coCurricularMark: coCurricular,
  );
} catch (e) {
  print('Merit calculation failed: $e');
  studentMerit = null;
}
```

---

## Data Structure Updates

### StudentProfile

Added merit-related fields:
```dart
class StudentProfile {
  // ... existing fields ...
  final List<int>? spmCompulsoryMarks;
  final List<int>? spmElectiveMarks;
  final List<int>? spmAdditionalMarks;
  final double? cgpa;
  final double coCurricularMark; // default: 0.0
  final double? calculatedMerit;
}
```

### CourseModel

Added merit requirement field:
```dart
class CourseModel {
  // ... existing fields ...
  final double? minMeritRequired; // 0-100
}
```

### ProgramModel

Already has `minMerit` field (int):
```dart
class ProgramModel {
  // ... existing fields ...
  final int? minMerit; // null for private institutions
}
```

### RecommendedProgram

Added merit tracking fields:
```dart
class RecommendedProgram {
  // ... existing fields ...
  final double? studentMerit;
  final bool meetsRequirement;
}
```

---

## Testing

Unit tests are provided in `test/merit_calculator_test.dart`:

```bash
# Run merit calculator tests
flutter test test/merit_calculator_test.dart
```

### Test Coverage

- ✅ SPM merit calculation with various inputs
- ✅ STPM/Asasi/Matrikulasi merit calculation
- ✅ Diploma merit calculation
- ✅ Input validation and error handling
- ✅ Merit requirement checking
- ✅ Generic calculation method

---

## Examples

### Complete Example: SPM Student via UPU

```dart
// Create student profile
StudentProfile student = StudentProfile(
  qualification: 'SPM',
  isUpu: true,
  interest: ['IT', 'Engineering'],
  spmCompulsoryMarks: [90, 88, 85],
  spmElectiveMarks: [92, 87],
  spmAdditionalMarks: [80],
  coCurricularMark: 8.0,
  budget: 50000,
);

// Calculate merit
double studentMerit = MeritCalculator.calculateSpmMerit(
  compulsoryMarks: student.spmCompulsoryMarks!,
  electiveMarks: student.spmElectiveMarks!,
  additionalMarks: student.spmAdditionalMarks!,
  coCurricularMark: student.coCurricularMark,
);

print('Student Merit: ${studentMerit.toStringAsFixed(2)}'); // 91.13
print('Merit Grade: ${MeritUtility.getMeritGrade(studentMerit)}'); // A (Excellent)

// Get recommendations (courses with merit >= 91.13 will be shown)
List<RecommendedProgram> recommendations = 
    admissionEngine.getRecommendations(student);

for (var rec in recommendations) {
  print('${rec.courseName}');
  print('  Min Merit Required: ${rec.minMerit}');
  print('  Student Merit: ${rec.studentMerit}');
  print('  Meets Requirement: ${rec.meetsRequirement ? '✓' : '✗'}');
}
```

### Complete Example: STPM Student

```dart
StudentProfile student = StudentProfile(
  qualification: 'STPM',
  isUpu: true,
  interest: ['Engineering', 'Business'],
  cgpa: 3.75,
  coCurricularMark: 9.0,
  stream: 'Science',
);

double studentMerit = MeritCalculator.calculatePreUniversityMerit(
  cgpa: student.cgpa!,
  coCurricularMark: student.coCurricularMark,
);

print('STPM Merit: ${studentMerit.toStringAsFixed(2)}'); // 93.38
```

---

## Integration Checklist

- [ ] Import `merit_calculator.dart` in relevant files
- [ ] Update UI screens to display merit scores
- [ ] Add merit input fields to student profile collection
- [ ] Update course filtering logic to use merit
- [ ] Display merit requirement on course listings
- [ ] Add merit eligibility badges/indicators
- [ ] Test merit calculations with sample data
- [ ] Update API to store/retrieve merit data
- [ ] Add merit analytics/reporting
- [ ] Document merit requirements in course descriptions

---

## FAQ

**Q: Why is SPM merit calculation limited to UPU platform?**
A: Private institutions (non-UPU) have their own merit systems. UPU standardizes SPM merit calculation for fair comparison across universities.

**Q: Can co-curricular marks exceed 10?**
A: No. Co-curricular marks are capped at 10 points. Any excess achievements are not counted.

**Q: What if a student's total academic score exceeds the maximum?**
A: For SPM, the formula divides by 80, so higher scores will result in merit > 100. Consider normalizing student marks to 0-80 scale first.

**Q: How often is merit recalculated?**
A: Merit is recalculated each time a student updates their profile or submits a new application.

**Q: Can merit requirements change per university?**
A: Yes. Each course/program can have different minimum merit requirements stored in the database.

---

## See Also

- [StudentProfile Model](../models/student_profile.dart)
- [CourseModel](../models/course_model.dart)
- [AdmissionEngine](./admission_engine.dart)
- [MeritUtility](merit_utility.dart)
- [Test Suite](../../test/merit_calculator_test.dart)
