import 'package:file_picker/file_picker.dart';
import '../models/student_profile.dart';
import 'admission_engine.dart';

class AdviceModel {
  final String title;
  final String advice;
  final String type; // 'warning', 'info', 'positive', 'opportunity'
  final String? action;

  AdviceModel({
    required this.title,
    required this.advice,
    required this.type,
    this.action,
  });
}

class AdviceEngine {
  /// Check if student is thinking big (high ambition)
  bool _isThinkingBig(Map<String, String> grades) {
    final gradeValues = {
      'A+': 4.0, 'A': 3.9, 'A-': 3.7,
      'B+': 3.3, 'B': 3.0, 'B-': 2.7,
      'C+': 2.3, 'C': 2.0, 'C-': 1.7,
      'D': 1.0, 'D+': 1.3, 'E': 0.0,
      'A1': 4.0, 'A2': 3.8, 'B3': 3.3, 'B4': 3.0, 'B5': 2.7,
      'B6': 2.5, 'C7': 2.0, 'C8': 1.5, 'F9': 0.0,
      'G': 0.5,
    };

    // Calculate GPA
    double gpaSum = 0;
    int validGrades = 0;
    int topGrades = 0;

    for (var entry in grades.entries) {
      double? value = gradeValues[entry.value];
      if (value != null) {
        gpaSum += value;
        validGrades++;
        if (value >= 3.7) topGrades++; // A- or better
      }
    }

    double gpa = validGrades > 0 ? gpaSum / validGrades : 0;
    
    // Student is thinking big if GPA >= 3.5 or has 50%+ top grades
    return gpa >= 3.5 || (topGrades > 0 && (topGrades / validGrades) >= 0.5);
  }

  /// Generate all applicable advice for the student profile
  List<AdviceModel> generateAdvice({
    required StudentProfile student,
    required Map<String, String> grades,
    required List<RecommendedProgram> recommendations,
    required PlatformFile? resumeFile,
  }) {
    List<AdviceModel> advice = [];
    bool thinkingBig = _isThinkingBig(grades);

    // If thinking big, add motivational advice first
    if (thinkingBig) {
      advice.addAll(_generateAmbitionAdvice(student, grades));
    }

    // Check for grade-interest mismatches
    advice.addAll(_checkGradeInterestMismatch(student, grades, thinkingBig));

    // Check for grade-requirement mismatches
    advice.addAll(
      _checkGradeRequirementMismatch(student, grades, recommendations, thinkingBig),
    );

    // Check for subject-interest mismatches
    advice.addAll(_checkSubjectInterestMismatch(student, grades, thinkingBig));

    // Resume-based advice
    if (resumeFile != null) {
      advice.addAll(_generateResumeBasedAdvice(student, resumeFile, thinkingBig));
    }

    // Budget vs grades matching
    advice.addAll(_checkBudgetGradeAlignment(student, grades, thinkingBig));

    // Overall performance advice
    advice.addAll(_generatePerformanceAdvice(student, grades, thinkingBig));

    return advice;
  }

  /// Generate motivational advice for ambitious students
  List<AdviceModel> _generateAmbitionAdvice(
    StudentProfile student,
    Map<String, String> grades,
  ) {
    List<AdviceModel> advice = [];

    // Top university opportunities
    advice.add(
      AdviceModel(
        title: '🚀 Aim for Excellence!',
        advice:
            'Your strong academic performance puts you in a competitive position for Malaysia\'s top universities (UM, UKM, USM, UPM). Don\'t settle for less than your potential. Target degree programs at prestigious institutions and consider pursuing scholarships for further studies abroad after your bachelor\'s degree.',
        type: 'opportunity',
        action: 'Apply to UM, UKM, USM, UPM, and international universities for scholarship programs',
      ),
    );

    // Specialized programs
    advice.add(
      AdviceModel(
        title: '⭐ Explore Specialized Tracks',
        advice:
            'With your caliber, pursue specialized programs like AI, Data Science, Software Engineering, or other niche fields that are high-demand in the job market. These programs often lead to better career prospects and higher starting salaries.',
        type: 'opportunity',
        action: 'Research specialized degree programs at top 20 Malaysian universities',
      ),
    );

    // International opportunities
    advice.add(
      AdviceModel(
        title: '🌍 Consider International Education',
        advice:
            'You\'re a strong candidate for international universities. Consider applying to quality institutions in Singapore, Australia, UK, or Canada if financially feasible. A degree from these regions significantly boosts career opportunities globally.',
        type: 'positive',
        action:
            'Explore scholarships from countries like Australia (AusAID), UK (Chevening), or Singapore (ASEAN scholarships)',
      ),
    );

    return advice;
  }

  /// Check if grades and subjects match student interests
  List<AdviceModel> _checkGradeInterestMismatch(
    StudentProfile student,
    Map<String, String> grades,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    // Define subject-to-interest mappings
    final subjectInterestMap = {
      'Mathematics': ['Engineering', 'Technology', 'Science', 'Finance'],
      'Physics': ['Engineering', 'Science', 'Technology'],
      'Chemistry': ['Engineering', 'Science', 'Medicine', 'Pharmacy'],
      'Biology': ['Medicine', 'Science', 'Pharmacy', 'Health'],
      'English': ['Business', 'Law', 'Communication', 'Liberal Arts'],
      'Bahasa Melayu': ['Business', 'Communication', 'Law'],
      'History': ['Social Sciences', 'Law', 'Education'],
      'Pengajian Am': ['Business', 'Social Sciences', 'Law'],
      'Accounting': ['Finance', 'Business', 'Accounting'],
      'Economics': ['Finance', 'Business', 'Economics'],
      'Computer Science': ['Technology', 'Engineering', 'IT'],
      'Advanced Maths': ['Engineering', 'Science', 'Finance', 'Data Science'],
    };

    // Map grade letters to numeric values
    final gradeValues = {
      'A+': 4.0, 'A': 3.9, 'A-': 3.7,
      'B+': 3.3, 'B': 3.0, 'B-': 2.7,
      'C+': 2.3, 'C': 2.0, 'C-': 1.7,
      'D': 1.0, 'D+': 1.3, 'E': 0.0,
      'A1': 4.0, 'A2': 3.8, 'B3': 3.3, 'B4': 3.0, 'B5': 2.7,
      'B6': 2.5, 'C7': 2.0, 'C8': 1.5, 'F9': 0.0,
      'G': 0.5,
    };

    // Check each grade
    for (var entry in grades.entries) {
      String subject = entry.key;
      String grade = entry.value;
      double? gradeValue = gradeValues[grade];

      // If subject doesn't match any interests
      final relatedInterests = subjectInterestMap[subject] ?? [];
      bool hasMatchingInterest = relatedInterests.any(
        (interest) => student.interest.any((si) => si.toLowerCase().contains(
              interest.toLowerCase(),
            )),
      );

      if (!hasMatchingInterest && relatedInterests.isNotEmpty) {
        String suggestion = 'You took $subject but it doesn\'t directly align with your interests (${student.interest.join(', ')}).';
        if (gradeValue != null && gradeValue >= 3.0) {
          if (thinkingBig) {
            suggestion +=
                ' However, your excellent grade ($grade) shows mastery! Consider leveraging this strength across multiple disciplines - many top companies value interdisciplinary expertise.';
            advice.add(
              AdviceModel(
                title: 'Unique Strength: Interdisciplinary Edge',
                advice: suggestion,
                type: 'opportunity',
                action:
                    'Pursue double degrees or programs combining ${subject} with ${student.interest.first}',
              ),
            );
          } else {
            suggestion +=
                ' However, your strong grade ($grade) shows capability. Consider roles that connect both areas.';
            advice.add(
              AdviceModel(
                title: 'Alternative Career Path',
                advice: suggestion,
                type: 'opportunity',
                action:
                    'Explore interdisciplinary programs combining ${subject} with your interests',
              ),
            );
          }
        } else {
          suggestion +=
              ' Consider strengthening core subjects related to your interests in future studies.';
          advice.add(
            AdviceModel(
              title: 'Subject-Interest Gap',
              advice: suggestion,
              type: 'info',
              action: 'Focus on subjects aligned with ${student.interest.first}',
            ),
          );
        }
      }
    }

    return advice;
  }

  /// Check if grades meet course requirements
  List<AdviceModel> _checkGradeRequirementMismatch(
    StudentProfile student,
    Map<String, String> grades,
    List<RecommendedProgram> recommendations,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    final gradeToNumber = {
      'A+': 100, 'A': 95, 'A-': 90,
      'B+': 85, 'B': 80, 'B-': 75,
      'C+': 70, 'C': 65, 'C-': 60,
      'D': 50, 'D+': 55, 'E': 40,
      'A1': 100, 'A2': 95, 'B3': 85, 'B4': 80, 'B5': 75,
      'B6': 70, 'C7': 65, 'C8': 60, 'F9': 40,
      'G': 45,
    };

    // Calculate average grade
    double gradeSum = 0;
    int validGrades = 0;

    for (var entry in grades.entries) {
      int? value = gradeToNumber[entry.value];
      if (value != null) {
        gradeSum += value;
        validGrades++;
      }
    }

    double averageGrade =
        validGrades > 0 ? gradeSum / validGrades : 0;

    // Check against course requirements
    for (var course in recommendations) {
      if (course.minMerit != null && averageGrade < course.minMerit!) {
        if (thinkingBig) {
          advice.add(
            AdviceModel(
              title: 'Push Yourself: Overcome the Gap',
              advice:
                  'Your average grade ($averageGrade.toStringAsFixed(1)) is slightly below the requirement (${course.minMerit}) for ${course.courseName}. Don\'t let this discourage you! Many ambitious students improve in foundation/diploma programs before transferring to their target degree. This is actually a proven pathway to success.',
              type: 'info',
              action:
                  'Consider foundation/diploma as stepping stones - many successful professionals took this route',
            ),
          );
        } else {
          advice.add(
            AdviceModel(
              title: 'Below Course Requirement',
              advice:
                  'Your average grade ($averageGrade.toStringAsFixed(1)) is below the requirement (${course.minMerit}) for ${course.courseName}. You may still apply, but consider focusing on courses with flexible entry requirements or repeating subjects to improve grades.',
              type: 'warning',
              action:
                  'Look for foundation or diploma programs as stepping stones',
            ),
          );
        }
        break;
      }
    }

    return advice;
  }

  /// Check if subjects align with stated interests
  List<AdviceModel> _checkSubjectInterestMismatch(
    StudentProfile student,
    Map<String, String> grades,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    // If student is interested in technical fields, they should have Math/Science
    bool interestedInTech = student.interest.any(
      (i) => ['Technology', 'Engineering', 'IT', 'Science'].any(
        (t) => i.toLowerCase().contains(t.toLowerCase()),
      ),
    );

    bool hasMathOrScience = grades.keys.any((s) {
      String lower = s.toLowerCase();
      return lower.contains('math') ||
          lower.contains('physics') ||
          lower.contains('chemistry') ||
          lower.contains('science') ||
          lower.contains('computer');
    });

    if (interestedInTech && !hasMathOrScience) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: 'Skill Gap Alert: Immediate Action Required',
            advice:
                'You\'re interested in ${student.interest.join(", ")} but lack formal Math/Science qualifications. This is a critical gap for your ambitions! However, Don\'t panic - you can catch up through intensive online courses. Many successful tech professionals bridged this gap.',
            type: 'warning',
            action:
                'Urgently enroll in MIT OpenCourseWare, Khan Academy, or Coursera Math/Physics fundamentals',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Missing Key Subjects',
            advice:
                'You\'re interested in ${student.interest.join(", ")} but don\'t have Mathematics or Science subjects. Consider taking additional courses or certifications to strengthen your profile.',
            type: 'warning',
            action: 'Enroll in online Math/Science courses from platforms like Coursera or edX',
          ),
        );
      }
    }

    // If interested in Business/Law, should have strong languages
    bool interestedInBusiness = student.interest.any(
      (i) => ['Business', 'Law', 'Commerce', 'Accounting'].any(
        (t) => i.toLowerCase().contains(t.toLowerCase()),
      ),
    );

    bool hasLanguage = grades.keys.any((s) {
      String lower = s.toLowerCase();
      return lower.contains('english') ||
          lower.contains('bahasa') ||
          lower.contains('language');
    });

    if (interestedInBusiness && !hasLanguage) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: 'Competitive Advantage: Language Mastery',
            advice:
                'Global business leaders are multilingual. Your lack of formal language training can be turned into a competitive advantage by proactively building fluency in English, Mandarin, or other business languages.',
            type: 'opportunity',
            action:
                'Take TOEFL/IELTS exams and learn Mandarin/Spanish for global competitiveness',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Language Skills Important',
            advice:
                'Strong language skills are crucial for ${student.interest.join(", ")} careers. Develop your English and other language proficiency.',
            type: 'info',
            action:
                'Take TOEFL/IELTS exams and consider language enrichment programs',
          ),
        );
      }
    }

    return advice;
  }

  /// Generate advice based on resume content (simulated)
  List<AdviceModel> _generateResumeBasedAdvice(
    StudentProfile student,
    PlatformFile resumeFile,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    // Simulated resume analysis
    if (resumeFile.size > 0) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: '💼 Your Resume is Your Secret Weapon',
            advice:
                'You\'ve uploaded a resume showing real-world experience! This significantly strengthens your profile. Ambitious universities reward practical experience. Make sure to highlight leadership roles, innovations, or measurable impact - universities love candidates who combine academics with action.',
            type: 'positive',
            action:
                'Highlight leadership, measurable impact, and innovative projects in your resume',
          ),
        );

        advice.add(
          AdviceModel(
            title: '🏆 Build an Unstoppable Portfolio',
            advice:
                'With your resume + strong grades, create a comprehensive portfolio showcasing projects, certifications, and achievements. This transforms you from just another applicant into a standout candidate that top universities actively recruit.',
            type: 'opportunity',
            action:
                'Create professional portfolios on GitHub (tech), Behance (design), LinkedIn (all fields)',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Resume Highlights',
            advice:
                'You\'ve uploaded a resume! Universities will consider your work experience, projects, and extracurricular activities alongside your grades. Make sure it highlights experiences relevant to ${student.interest.join(", ")}.',
            type: 'positive',
            action:
                'Highlight experiences related to your chosen fields in your resume',
          ),
        );

        advice.add(
          AdviceModel(
            title: 'Build Your Portfolio',
            advice:
                'Combine your resume with a portfolio of projects or achievements. Many universities appreciate evidence of practical skills beyond academic grades.',
            type: 'opportunity',
            action: 'Create a portfolio on GitHub (tech), Behance (design), or similar platforms',
          ),
        );
      }
    }

    return advice;
  }

  /// Check alignment between budget and grade quality
  List<AdviceModel> _checkBudgetGradeAlignment(
    StudentProfile student,
    Map<String, String> grades,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    if (student.budget == null) return advice;

    // Count good grades
    int goodGrades = grades.values
        .where((g) =>
            g.startsWith('A') ||
            g.startsWith('B') ||
            g == 'B3' ||
            g == 'B4' ||
            g == 'B5' ||
            g == 'A1' ||
            g == 'A2')
        .length;

    // If low budget but good grades
    if (student.budget! < 20000 && goodGrades >= 3) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: '🎓 Scholarship Excellence: Your Path to Top Universities',
            advice:
                'Your strong academic performance (${goodGrades} strong grades) + low budget = PERFECT SCHOLARSHIP CANDIDATE! Many top Malaysian universities offer full scholarships to high-achieving students. Additionally, explore government scholarships (MyBrain15, Yayasan Pelaburan Khazanah) and corporate scholarships. You could study at UM or UKM fully funded!',
            type: 'opportunity',
            action:
                'Apply to government scholarships (MyBrain15, Khazanah), university scholarships, and corporate programs immediately',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Scholarship Opportunity',
            advice:
                'Your strong academic performance (${goodGrades} strong grades) combined with your budget constraints makes you a strong candidate for scholarships and financial aid. Apply to university grants and government schemes like PTPTN.',
            type: 'opportunity',
            action:
                'Search and apply for scholarships at MalaysiaScholarships.com and university websites',
          ),
        );
      }
    }

    // If high budget but average grades
    if (student.budget! > 40000 && goodGrades < 2) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: 'Premium Education Investment',
            advice:
                'Your substantial budget opens doors to world-class private/international universities with excellent facilities and industry connections. While your current grades are average, premium institutions often provide excellent support programs. Consider top private universities offering strong career pathways despite entry requirements.',
            type: 'opportunity',
            action:
                'Target Monash, Taylor\'s, Sunway, INTI, Heriot-Watt - universities with strong industry partnerships',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Budget Strategy',
            advice:
                'With your budget, you have flexibility to choose private institutions. Use this to your advantage - find programs with flexible entry requirements that match your interests.',
            type: 'info',
            action:
                'Look at private universities offering pathway programs or foundation courses',
          ),
        );
      }
    }

    return advice;
  }

  /// Generate overall performance-based advice
  List<AdviceModel> _generatePerformanceAdvice(
    StudentProfile student,
    Map<String, String> grades,
    bool thinkingBig,
  ) {
    List<AdviceModel> advice = [];

    final gradeValues = {
      'A+': 4.0, 'A': 3.9, 'A-': 3.7,
      'B+': 3.3, 'B': 3.0, 'B-': 2.7,
      'C+': 2.3, 'C': 2.0, 'C-': 1.7,
      'D': 1.0, 'D+': 1.3, 'E': 0.0,
      'A1': 4.0, 'A2': 3.8, 'B3': 3.3, 'B4': 3.0, 'B5': 2.7,
      'B6': 2.5, 'C7': 2.0, 'C8': 1.5, 'F9': 0.0,
      'G': 0.5,
    };

    // Calculate GPA
    double gpaSum = 0;
    int validGrades = 0;

    for (var entry in grades.entries) {
      double? value = gradeValues[entry.value];
      if (value != null) {
        gpaSum += value;
        validGrades++;
      }
    }

    double gpa = validGrades > 0 ? gpaSum / validGrades : 0;

    if (gpa >= 3.5) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: '⭐⭐⭐ Outstanding Achievement!',
            advice:
                'Your GPA of $gpa is EXCEPTIONAL! You\'re in the top tier of students nationally. This opens EVERY door - UM, UKM, USM, international universities, government scholarships, and corporate programs are all within reach. You have the academic credentials for any program you choose. Now focus on specialization and personal development.',
            type: 'positive',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Excellent Academic Performance',
            advice:
                'Your GPA of $gpa is excellent! You\'re competitive for top universities and should aim high. Don\'t limit yourself - apply to prestigious institutions.',
            type: 'positive',
          ),
        );
      }
    } else if (gpa >= 2.5) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: '✅ Solid Foundation: Good Starting Point',
            advice:
                'Your GPA of $gpa shows you\'re a capable student with decent fundamentals. While not in the top tier, you still have good options at solid universities. Focus on differentiating yourself through extracurriculars, projects, or skills development. Many successful people didn\'t have perfect grades.',
            type: 'positive',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Solid Academic Foundation',
            advice:
                'Your GPA of $gpa is good. You have decent options, especially at private institutions. Consider complementing your academics with extracurriculars.',
            type: 'positive',
          ),
        );
      }
    } else if (gpa >= 1.5) {
      if (thinkingBig) {
        advice.add(
          AdviceModel(
            title: 'Strategic Pathway to Success',
            advice:
                'Your GPA of $gpa suggests a foundation or diploma program is your strategic starting point. This isn\'t a setback - it\'s a common pathway for ambitious students! Many use these 2 years to dramatically improve, then transfer to top degree programs. University life often helps students flourish academically.',
            type: 'info',
            action: 'Target foundation/diploma programs with clear "upgrade pathways" to degree programs',
          ),
        );
      } else {
        advice.add(
          AdviceModel(
            title: 'Consider Alternative Pathways',
            advice:
                'Your GPA of $gpa suggests foundation or diploma programs might be better starting points. These allow you to improve and transfer to degree programs later.',
            type: 'info',
            action: 'Look for foundation programs with supportive teaching methods',
          ),
        );
      }
    } else {
      advice.add(
        AdviceModel(
          title: 'Start Your Journey Strategically',
          advice:
              'Your GPA of $gpa indicates you may face challenges with traditional degree programs right now. However, this doesn\'t define your future! Many successful individuals started with vocational training or diploma programs to build confidence and skills.',
          type: 'warning',
          action: 'Explore diploma programs or vocational certifications in your field of interest',
        ),
      );
    }

    return advice;
  }
}
