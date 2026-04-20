import 'package:flutter_test/flutter_test.dart';

/// 📅 Mock Timetable Logic for Testing
class FakeTimetableService {
  final Map<String, List<Map<String, dynamic>>> _timetable = {};

  void addSlot(String day, Map<String, dynamic> slot) {
    _timetable.putIfAbsent(day, () => []).add(slot);
    // Sort by timeValue
    _timetable[day]!.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
  }

  List<Map<String, dynamic>> getSlots(String day) => _timetable[day] ?? [];

  bool hasConflict(String day, double timeValue) {
    return getSlots(day).any((s) => s['timeValue'] == timeValue);
  }
}

void main() {
  group('📅 Timetable & Scheduling Unit Tests', () {
    late FakeTimetableService service;

    setUp(() {
      service = FakeTimetableService();
    });

    test('✅ Add and sort multiple slots by time', () {
      service.addSlot('Monday', {'course': 'CS101', 'timeValue': 14.0}); // 2 PM
      service.addSlot('Monday', {'course': 'MA201', 'timeValue': 09.0}); // 9 AM
      
      final slots = service.getSlots('Monday');
      expect(slots.first['course'], 'MA201'); // 9 AM should be first
      expect(slots.last['course'], 'CS101');  // 2 PM should be second
    });

    test('✅ Detect time conflicts correctly', () {
      service.addSlot('Tuesday', {'course': 'BIO', 'timeValue': 10.0});
      
      expect(service.hasConflict('Tuesday', 10.0), true);
      expect(service.hasConflict('Tuesday', 11.0), false);
    });

    test('✅ Handle empty day retrieval', () {
      expect(service.getSlots('Sunday').isEmpty, true);
    });

    test('✅ Maintain separate schedules for different days', () {
      service.addSlot('Monday', {'course': 'A', 'timeValue': 9.0});
      service.addSlot('Friday', {'course': 'B', 'timeValue': 9.0});
      
      expect(service.getSlots('Monday').length, 1);
      expect(service.getSlots('Friday').length, 1);
      expect(service.getSlots('Monday').first['course'], 'A');
    });
  });
}
