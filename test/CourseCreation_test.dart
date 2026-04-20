import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class FakeCourseService {
  final List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> get courses => _courses;

  String? registerCourse({
    required String code,
    required String title,
    required int credits,
    required Color color,
  }) {
    if (code.trim().isEmpty || title.trim().isEmpty) {
      return "Fields cannot be empty";
    }

    if (credits < 0 || credits > 10) {
      return "Invalid credits";
    }

    if (_courses.any((c) => c['code'] == code)) {
      return "Duplicate course code";
    }

    _courses.add({
      'code': code,
      'title': title,
      'credits': credits,
      'color': color,
    });

    return null;
  }

  bool deleteCourse(String code) {
    int initialLen = _courses.length;
    _courses.removeWhere((c) => c['code'] == code);
    return _courses.length < initialLen;
  }
}

void main() {
  group('📚 Course Creation Tests', () {
    late FakeCourseService service;

    setUp(() {
      service = FakeCourseService();
    });

    // ✅ Valid Registration
    test('✅ Register: valid course should be added', () {
      print('Input -> code: CS101, title: Intro, credits: 4');

      final result = service.registerCourse(
        code: 'CS101',
        title: 'Intro',
        credits: 4,
        color: Colors.blue,
      );

      print('Output -> result: $result');
      print('Courses -> ${service.courses}');

      expect(result, null);
      expect(service.courses.length, 1);
    });

    // ❌ Empty Code
    test('❌ Register: empty code should fail', () {
      print('Input -> code: EMPTY');

      final result = service.registerCourse(
        code: '',
        title: 'Intro',
        credits: 4,
        color: Colors.blue,
      );

      print('Output -> result: $result');

      expect(result, "Fields cannot be empty");
    });

    // ❌ Duplicate
    test('❌ Register: duplicate course code should fail', () {
      service.registerCourse(
        code: 'CS101',
        title: 'Intro',
        credits: 4,
        color: Colors.blue,
      );

      print('Input -> duplicate code: CS101');

      final result = service.registerCourse(
        code: 'CS101',
        title: 'Intro 2',
        credits: 3,
        color: Colors.red,
      );

      print('Output -> result: $result');

      expect(result, "Duplicate course code");
    });

    // ❌ Invalid Credits
    test('❌ Register: credits > 10 should fail', () {
      print('Input -> credits: 11');

      final result = service.registerCourse(
        code: 'BIG',
        title: 'Hard',
        credits: 11,
        color: Colors.black,
      );

      print('Output -> result: $result');

      expect(result, "Invalid credits");
    });

    // ✅ Zero Credit
    test('✅ Register: zero credits should be allowed', () {
      print('Input -> credits: 0');

      final result = service.registerCourse(
        code: 'LAB',
        title: 'Lab',
        credits: 0,
        color: Colors.green,
      );

      print('Output -> result: $result');

      expect(result, null);
    });

    // ✅ Deletion
    test('✅ Delete: course should be removed successfully', () {
      service.registerCourse(
        code: 'DEL',
        title: 'Remove Me',
        credits: 1,
        color: Colors.grey,
      );

      print('Before delete -> ${service.courses}');

      final deleted = service.deleteCourse('DEL');

      print('Output -> deleted: $deleted');
      print('After delete -> ${service.courses}');

      expect(deleted, true);
      expect(service.courses.length, 0);
    });

    // ❌ Delete non-existing
    test('❌ Delete: non-existing course should return false', () {
      print('Input -> delete code: UNKNOWN');

      final deleted = service.deleteCourse('UNKNOWN');

      print('Output -> deleted: $deleted');

      expect(deleted, false);
    });
  });
}