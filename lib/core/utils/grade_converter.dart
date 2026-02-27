class GradeConverter {
  // Convert SPM/STPM letter grades to numeric marks
  static int spmGradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return 100;
      case 'A-':
        return 90;
      case 'B+':
        return 85;
      case 'B':
        return 80;
      case 'B-':
        return 75;
      case 'C+':
        return 70;
      case 'C':
        return 65;
      case 'C-':
        return 60;
      case 'D':
        return 50;
      case 'E':
        return 40;
      case 'G':
        return 0;
      default:
        return 0;
    }
  }

  static int stpmGradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 100;
      case 'A-':
        return 90;
      case 'B+':
        return 85;
      case 'B':
        return 80;
      case 'B-':
        return 75;
      case 'C+':
        return 70;
      case 'C':
        return 65;
      case 'C-':
        return 60;
      case 'D':
        return 50;
      case 'E':
        return 40;
      default:
        return 0;
    }
  }
}
