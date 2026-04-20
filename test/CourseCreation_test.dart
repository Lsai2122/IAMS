import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class FakeCourseService {
  final List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> get courses => _courses;

  String? registerCourse({required String code, required String title, required int credits, required Color color}) {
    if (code.trim().isEmpty || title.trim().isEmpty) return "Fields cannot be empty";
    if (credits < 0 || credits > 10) return "Invalid credits";
    if (_courses.any((c) => c['code'] == code)) return "Duplicate course code";
    
    _courses.add({'code': code, 'title': title, 'credits': credits, 'color': color});
    return null;
  }

  bool deleteCourse(String code) {
    int initialLen = _courses.length;
    _courses.removeWhere((c) => c['code'] == code);
    return _courses.length < initialLen;
  }
}

void main() {
  group('📚 Course Creation Exhaustive Tests', () {
    late FakeCourseService service;
    setUp(() => service = FakeCourseService());

    test('✅ Valid Registration', () {
      expect(service.registerCourse(code: 'CS101', title: 'Intro', credits: 4, color: Colors.blue), null);
      expect(service.courses.length, 1);
    });

    test('❌ Empty Code Failure', () {
      expect(service.registerCourse(code: '', title: 'Intro', credits: 4, color: Colors.blue), "Fields cannot be empty");
    });

    test('❌ Duplicate Code Protection', () {
      service.registerCourse(code: 'CS101', title: 'Intro', credits: 4, color: Colors.blue);
      expect(service.registerCourse(code: 'CS101', title: 'Intro 2', credits: 3, color: Colors.red), "Duplicate course code");
    });

    test('❌ Unrealistic Credits (>10)', () {
      expect(service.registerCourse(code: 'BIG', title: 'Hard', credits: 11, color: Colors.black), "Invalid credits");
    });

    test('✅ Zero Credit Support', () {
      expect(service.registerCourse(code: 'LAB', title: 'Lab', credits: 0, color: Colors.green), null);
    });

    test('✅ Course Deletion Logic', () {
      service.registerCourse(code: 'DEL', title: 'Remove Me', credits: 1, color: Colors.grey);
      expect(service.deleteCourse('DEL'), true);
      expect(service.courses.length, 0);
    });
  });
}
