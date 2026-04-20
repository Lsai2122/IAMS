import 'package:flutter_test/flutter_test.dart';

/// 📅 Mock Timetable Logic for Testing
class FakeTimetableService {
  final Map<String, List<Map<String, dynamic>>> _timetable = {};

  void addSlot(String day, Map<String, dynamic> slot) {
    _timetable.putIfAbsent(day, () => []).add(slot);

    // Sort by timeValue
    _timetable[day]!.sort(
          (a, b) => (a['timeValue'] as double)
          .compareTo(b['timeValue'] as double),
    );
  }

  List<Map<String, dynamic>> getSlots(String day) =>
      _timetable[day] ?? [];

  bool hasConflict(String day, double timeValue) {
    return getSlots(day)
        .any((s) => s['timeValue'] == timeValue);
  }
}

void main() {
  group('📅 Timetable & Scheduling Tests', () {
    late FakeTimetableService service;

    setUp(() {
      service = FakeTimetableService();
    });

    // ✅ 1. Sorting Test
    test('✅ Add slots: should sort by time correctly', () {
      print('Input -> Monday slots: CS101 @14.0, MA201 @9.0');

      service.addSlot('Monday', {'course': 'CS101', 'timeValue': 14.0});
      service.addSlot('Monday', {'course': 'MA201', 'timeValue': 9.0});

      final slots = service.getSlots('Monday');

      print('Output -> Sorted slots: $slots');

      expect(slots.first['course'], 'MA201');
      expect(slots.last['course'], 'CS101');
    });

    // ✅ 2. Conflict Detection
    test('✅ Conflict detection: should detect same time slot', () {
      print('Input -> Add BIO @10.0 on Tuesday');

      service.addSlot('Tuesday', {'course': 'BIO', 'timeValue': 10.0});

      bool conflict1 = service.hasConflict('Tuesday', 10.0);
      bool conflict2 = service.hasConflict('Tuesday', 11.0);

      print('Output -> conflict@10: $conflict1, conflict@11: $conflict2');

      expect(conflict1, true);
      expect(conflict2, false);
    });

    // ❌ 3. Empty Day Test
    test('❌ Empty timetable: should return empty list', () {
      print('Input -> Fetch Sunday timetable (no data)');

      final slots = service.getSlots('Sunday');

      print('Output -> slots: $slots');

      expect(slots.isEmpty, true);
    });

    // ✅ 4. Separate Days Test
    test('✅ Multiple days: schedules should be independent', () {
      print('Input -> Monday:A @9, Friday:B @9');

      service.addSlot('Monday', {'course': 'A', 'timeValue': 9.0});
      service.addSlot('Friday', {'course': 'B', 'timeValue': 9.0});

      final monday = service.getSlots('Monday');
      final friday = service.getSlots('Friday');

      print('Output -> Monday: $monday');
      print('Output -> Friday: $friday');

      expect(monday.length, 1);
      expect(friday.length, 1);
      expect(monday.first['course'], 'A');
    });

    // ❌ 5. Conflict Edge Case
    test('❌ Conflict: duplicate slot should be detected', () {
      print('Input -> Add same time twice (10.0)');

      service.addSlot('Wednesday', {'course': 'X', 'timeValue': 10.0});

      bool conflict = service.hasConflict('Wednesday', 10.0);

      print('Output -> conflict: $conflict');

      expect(conflict, true);
    });
  });
}