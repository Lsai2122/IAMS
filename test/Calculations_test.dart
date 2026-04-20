import 'package:flutter_test/flutter_test.dart';

/// 📊 Mock Calculation Logic for Testing
class FakeAnalyticsService {
  final Map<String, double> gradePoints = {
    'O': 10.0, 'A+': 9.0, 'A': 8.0, 'B+': 7.0, 'B': 6.0, 'C': 5.0, 'P': 4.0, 'F': 0.0
  };

  /// Calculates Weighted GPA
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

  /// Calculates Attendance Percentage
  double calculateAttendance(int attended, int total) {
    if (total <= 0) return 0.0;
    return (attended / total) * 100;
  }

  /// Validates Grade Validity
  bool isValidGrade(String grade) => gradePoints.containsKey(grade);
}

void main() {
  group('📊 Academic Calculation Unit Tests', () {
    late FakeAnalyticsService service;

    setUp(() {
      service = FakeAnalyticsService();
    });

    test('✅ SUCCESS: Calculate correct weighted GPA', () {
      final courses = [
        {'grade': 'O', 'credits': 4}, // 10 * 4 = 40
        {'grade': 'B', 'credits': 3}, // 6 * 3 = 18
      ];
      // Total points: 58, Total credits: 7. GPA: 58/7 = 8.28...
      final gpa = service.calculateGPA(courses);
      expect(gpa, closeTo(8.28, 0.01));
    });

    test('✅ SUCCESS: Calculate attendance percentage', () {
      expect(service.calculateAttendance(15, 20), 75.0);
      expect(service.calculateAttendance(0, 10), 0.0);
      expect(service.calculateAttendance(10, 10), 100.0);
    });

    test('❌ FAIL: Handle zero total classes in attendance', () {
      expect(service.calculateAttendance(5, 0), 0.0);
    });

    test('❌ FAIL: GPA for empty course list should be 0', () {
      expect(service.calculateGPA([]), 0.0);
    });

    test('❌ FAIL: GPA for failed subjects (F grade)', () {
      final courses = [{'grade': 'F', 'credits': 4}];
      expect(service.calculateGPA(courses), 0.0);
    });

    test('✅ SUCCESS: Grade validation check', () {
      expect(service.isValidGrade('A+'), true);
      expect(service.isValidGrade('Z'), false);
    });
  });
}
