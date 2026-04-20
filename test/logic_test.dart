import 'package:flutter_test/flutter_test.dart';
import 'package:iams_app/controllers/academic_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcademicController Tests', () {
    late AcademicController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = AcademicController();
    });

    const String courseCode = 'BITRISE-SYNC';
    const String testDay = 'Wednesday';
    const String testDateKey = '2023-11-01';

    test('1. Course Registration Test', () {
      controller.registerPersonalCourse(
        code: courseCode,
        title: 'CI Pipeline Course',
        credits: 3,
        color: Colors.blue,
      );

      expect(
        controller.courses.any((c) => c['code'] == courseCode),
        true,
      );
    });

    test('2. Timetable Injection Test', () {
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

      expect(
        timetable.any((slot) => slot['courseCode'] == courseCode),
        true,
      );
    });

    test('3. Attendance Marking Test', () {
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

      expect(
        history.any((h) => h['id'] == slotId && h['status'] == true),
        true,
      );
    });

    test('4. Attendance Stats Test', () {
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

      expect(courseStats['personalHours'], 1);
    });
  });
}