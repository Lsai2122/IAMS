import 'package:flutter_test/flutter_test.dart';

/// 📊 Mock Calculation Logic for Testing
class FakeAnalyticsService {
  final Map<String, double> gradePoints = {
    'O': 10.0, 'A+': 9.0, 'A': 8.0, 'B+': 7.0,
    'B': 6.0, 'C': 5.0, 'P': 4.0, 'F': 0.0
  };

  double calculateGPA(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalCredits = 0;

    for (var c in courses) {
      final String grade = c['grade'] ?? 'N/A';
      if (gradePoints.containsKey(grade)) {
        final int credits = c['credits'] ?? 0;
        totalPoints += gradePoints[grade]! * credits;
        totalCredits += credits;
      }
    }

    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  double calculateAttendance(int attended, int total) {
    if (total <= 0) return 0.0;
    return (attended / total) * 100;
  }

  bool isValidGrade(String grade) =>
      gradePoints.containsKey(grade);
}

void main() {
  group('📊 Academic Calculation Tests', () {
    late FakeAnalyticsService service;

    setUp(() {
      service = FakeAnalyticsService();
    });

    // ✅ GPA Test
    test('✅ GPA: weighted calculation should be correct', () {
      final courses = [
        {'grade': 'O', 'credits': 4},
        {'grade': 'B', 'credits': 3},
      ];

      print('Input -> courses: $courses');

      final gpa = service.calculateGPA(courses);

      print('Output -> GPA: $gpa');

      expect(gpa, closeTo(8.28, 0.01));
    });

    // ✅ Attendance Test
    test('✅ Attendance: percentage calculation', () {
      print('Input -> attended: 15, total: 20');

      double result = service.calculateAttendance(15, 20);

      print('Output -> attendance: $result');

      expect(result, 75.0);
    });

    // ❌ Edge: Zero total
    test('❌ Attendance: zero total classes handled', () {
      print('Input -> attended: 5, total: 0');

      double result = service.calculateAttendance(5, 0);

      print('Output -> attendance: $result');

      expect(result, 0.0);
    });

    // ❌ Empty GPA
    test('❌ GPA: empty course list returns 0', () {
      print('Input -> courses: []');

      double gpa = service.calculateGPA([]);

      print('Output -> GPA: $gpa');

      expect(gpa, 0.0);
    });

    // ❌ Failed subject
    test('❌ GPA: failed subject should give 0 GPA', () {
      final courses = [{'grade': 'F', 'credits': 4}];

      print('Input -> courses: $courses');

      double gpa = service.calculateGPA(courses);

      print('Output -> GPA: $gpa');

      expect(gpa, 0.0);
    });

    // ✅ Grade validation
    test('✅ Grade Validation: valid vs invalid grades', () {
      print('Input -> grades: A+, Z');

      bool valid1 = service.isValidGrade('A+');
      bool valid2 = service.isValidGrade('Z');

      print('Output -> A+: $valid1, Z: $valid2');

      expect(valid1, true);
      expect(valid2, false);
    });
  });
}