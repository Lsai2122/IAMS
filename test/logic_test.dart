import 'package:flutter_test/flutter_test.dart';
import 'package:iams_app/controllers/academic_controller.dart';
import 'package:flutter/material.dart';

void main() {
  group('AcademicController Logic Tests', () {
    late AcademicController controller;

    setUp(() {
      controller = AcademicController();
    });

    test('Initial state should have zero courses', () {
      expect(controller.courses.length, 0);
    });

    test('Personal course registration should update local list', () {
      controller.registerPersonalCourse(
        code: 'TEST-101',
        title: 'Test Course',
        credits: 3,
        color: Colors.blue,
      );
      expect(controller.courses.length, 1);
      expect(controller.courses.first['isPersonal'], true);
    });

    test('To-Do list interaction should toggle completion status', () {
      controller.addTodo('Test Task', 'TEST-101');
      expect(controller.todoList.length, 1);
      expect(controller.todoList.first['isDone'], false);

      controller.toggleTodo(0);
      expect(controller.todoList.first['isDone'], true);
    });

    test('Attendance Stats should handle zero data gracefully', () {
      final stats = controller.getAttendanceStats();
      expect(stats.isEmpty, true);
    });
  });
}
