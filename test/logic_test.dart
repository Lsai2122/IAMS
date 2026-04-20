import 'package:flutter_test/flutter_test.dart';
import 'package:iams_app/controllers/academic_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcademicController Test Suite', () {
    late AcademicController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = AcademicController();
    });

    const String courseCode = 'BITRISE-SYNC';
    const String testDay = 'Wednesday';
    const String testDateKey = '2023-11-01';

    // ✅ 1. Course Registration (Positive)
    test('✅ Course Registration: valid input should succeed', () {
      print('Input -> code: $courseCode, credits: 3');

      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );

      print('Output -> courses: ${controller.courses}');

      expect(
        controller.courses.any((c) => c['code'] == courseCode),
        true,
      );
    });

    // ❌ 2. Course Registration (Negative)
    test('❌ Course Registration: empty code should fail', () {
      print('Input -> code: EMPTY');

      controller.registerPersonalCourse(
        code: '',
        title: 'Invalid Course',
        credits: 3,
        color: Colors.red,
      );

      print('Output -> courses: ${controller.courses}');

      expect(
        controller.courses.any((c) => c['code'] == ''),
        false,
      );
    });

    // ✅ 3. Timetable Injection (Positive)
    test('✅ Timetable: valid course should appear in timetable', () {
      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );

      controller.addClassToTimetable(
        testDay,
        courseCode,
        '02:00 PM',
        'Virtual Hall',
        14.0,
      );

      final timetable = controller.getTimetableForDate(DateTime(2023, 11, 1));

      print('Timetable -> $timetable');

      expect(
        timetable.any((slot) => slot['courseCode'] == courseCode),
        true,
      );
    });

    // ❌ 4. Timetable Negative
    test('❌ Timetable: wrong course should NOT exist', () {
      final timetable = controller.getTimetableForDate(DateTime(2023, 11, 1));

      print('Checking for invalid course in timetable');

      expect(
        timetable.any((slot) => slot['courseCode'] == 'WRONG'),
        false,
      );
    });

    // ✅ 5. Attendance Marking (Positive)
    test('✅ Attendance: marking attendance should be recorded', () {
      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );

      controller.addClassToTimetable(
        testDay,
        courseCode,
        '02:00 PM',
        'Virtual Hall',
        14.0,
      );

      final timetable = controller.getTimetableForDate(DateTime(2023, 11, 1));
      final slotId =
      timetable.firstWhere((slot) => slot['courseCode'] == courseCode)['id'];

      controller.markAttendance(testDateKey, slotId, true);

      final history = controller.getAttendanceHistory(courseCode);

      print('Attendance history -> $history');

      expect(
        history.any((h) => h['id'] == slotId && h['status'] == true),
        true,
      );
    });

    // ❌ 6. Attendance Negative
    test('❌ Attendance: invalid slot should not be recorded', () {
      controller.markAttendance('2023-11-01', 'invalid_id', true);

      final history = controller.getAttendanceHistory('INVALID');

      print('Invalid attendance history -> $history');

      expect(history.isEmpty, true);
    });

    // ✅ 7. Attendance Stats (Positive)
    test('✅ Stats: attendance stats should calculate correctly', () {
      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );

      controller.addClassToTimetable(
        testDay,
        courseCode,
        '02:00 PM',
        'Virtual Hall',
        14.0,
      );

      final timetable = controller.getTimetableForDate(DateTime(2023, 11, 1));
      final slotId =
      timetable.firstWhere((slot) => slot['courseCode'] == courseCode)['id'];

      controller.markAttendance(testDateKey, slotId, true);

      final stats = controller.getAttendanceStats();
      final courseStats =
      stats.firstWhere((s) => s['code'] == courseCode);

      print('Stats -> $courseStats');

      expect(courseStats['personalHours'], 1);
    });
  });
}