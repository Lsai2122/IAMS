import 'package:flutter_test/flutter_test.dart';
import 'package:iams_app/controllers/academic_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Required for SharedPreferences and other plugin mocks in CI
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcademicController Bitrise Integrated Workflow', () {
    late AcademicController controller;

    setUp(() async {
      // Initialize SharedPreferences with an empty state for a clean test
      SharedPreferences.setMockInitialValues({});
      controller = AcademicController();
    });

    test('End-to-End Workflow: Registration -> Timetable -> Attendance Mapping', () async {
      final String courseCode = 'BITRISE-SYNC';
      final String testDateKey = '2023-11-01'; 
      final String testDay = 'Wednesday';

      // 1. Validate Personal Course Creation
      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );
      
      expect(
        controller.courses.any((c) => c['code'] == courseCode), 
        true, 
        reason: 'The CI pipeline must successfully register a local course.'
      );

      // 2. Validate Timetable Slot Injection
      controller.addClassToTimetable(
        testDay,
        courseCode,
        '02:00 PM',
        'Virtual Hall',
        14.0,
      );

      // Check if slot appears on the specific date mapped to that day
      final timetable = controller.getTimetableForDate(DateTime(2023, 11, 1)); // This is a Wednesday
      
      expect(
        timetable.any((slot) => slot['courseCode'] == courseCode), 
        true, 
        reason: 'Timetable must correctly map template day to calendar date.'
      );
      
      final slotId = timetable.firstWhere((slot) => slot['courseCode'] == courseCode)['id'];

      // 3. Validate Attendance Logic & Stat Separation
      // Mark as present
      controller.markAttendance(testDateKey, slotId, true);
      
      final stats = controller.getAttendanceStats();
      final courseStats = stats.firstWhere((s) => s['code'] == courseCode);
      
      // Verification of Student-Marked Logic
      expect(
        courseStats['personalHours'], 
        1, 
        reason: 'Manual timetable entries must be calculated as Personal Study Hours, not official classes.'
      );
      
      final history = controller.getAttendanceHistory(courseCode);
      expect(
        history.any((h) => h['id'] == slotId && h['status'] == true), 
        true, 
        reason: 'Attendance history must record the manual study session.'
      );
    });
  });
}
