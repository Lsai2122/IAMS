import 'package:flutter/material.dart';
import 'dart:math';

class AcademicController extends ChangeNotifier {
  // Semester Boundaries
  DateTime semesterStart = DateTime(DateTime.now().year, 1, 1);
  DateTime semesterEnd = DateTime(DateTime.now().year, 12, 31);

  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS301',
      'title': 'Database Systems',
      'credits': 4,
      'faculty': 'Dr. Rao',
      'color': Colors.blue,
      'marks': {'Internal': 22, 'Mid-term': 45, 'Target': 90},
      'notes': ['Introduction to RDBMS', 'Normal Forms explained', 'SQL Join types'],
      'grade': 'A',
    },
    {
      'code': 'MA201',
      'title': 'Engineering Math',
      'credits': 3,
      'faculty': 'Dr. Patel',
      'color': Colors.orange,
      'marks': {'Internal': 18, 'Mid-term': 38, 'Target': 85},
      'notes': ['Complex Variables basics', 'Taylor Series expansion'],
      'grade': 'B+',
    },
    {
      'code': 'CS401',
      'title': 'Software Eng.',
      'credits': 3,
      'faculty': 'Dr. Kumar',
      'color': Colors.purple,
      'marks': {'Internal': 20, 'Mid-term': 42, 'Target': 88},
      'notes': ['Agile Methodology', 'SDLC Models overview'],
      'grade': 'A',
    },
    {
      'code': 'CS101',
      'title': 'Programming Lab',
      'credits': 2,
      'faculty': 'Dr. Smith',
      'color': Colors.teal,
      'marks': {'Internal': 24, 'Mid-term': 48, 'Target': 95},
      'notes': ['C Pointers exercises', 'Memory allocation tips'],
      'grade': 'O',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _weeklyTimetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  final Map<String, Map<String, bool>> _attendanceRecord = {};

  final List<Map<String, dynamic>> _todoList = [];
  final List<Map<String, dynamic>> _allEvents = [
    {'id': 1, 'title': 'Tech Fest 2025', 'date': 'Apr 20', 'category': 'Technical', 'isRegistered': false},
    {'id': 2, 'title': 'Cultural Night', 'date': 'Apr 25', 'category': 'Cultural', 'isRegistered': false},
  ];
  final List<Map<String, dynamic>> _notifications = [];

  AcademicController() {
    _initDefaultTimetable();
  }

  void _initDefaultTimetable() {
    _addClassInternal('Monday', 'CS301', '09:00 AM', 'Hall 102', 9.0);
    _addClassInternal('Monday', 'MA201', '11:00 AM', 'Room 405', 11.0);
    _addClassInternal('Tuesday', 'CS401', '01:00 PM', 'Hall 201', 13.0);
    _addClassInternal('Wednesday', 'CS101', '02:00 PM', 'Lab 03', 14.0);
  }

  String _generateSlotId() => "slot_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}";

  void _addClassInternal(String day, String courseCode, String time, String location, double timeValue) {
    _weeklyTimetable[day]!.add({
      'id': _generateSlotId(),
      'time': time,
      'courseCode': courseCode,
      'location': location,
      'timeValue': timeValue,
    });
  }

  List<Map<String, dynamic>> get courses => _courses;
  List<Map<String, dynamic>> get todoList => _todoList;
  List<Map<String, dynamic>> get allEvents => _allEvents;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get registeredEvents => _allEvents.where((e) => e['isRegistered'] == true).toList();

  double get gpa {
    final gradePoints = {'O': 10.0, 'A+': 9.0, 'A': 8.0, 'B+': 7.0, 'B': 6.0, 'C': 5.0, 'P': 4.0, 'F': 0.0};
    double totalPoints = 0;
    int totalCredits = 0;
    for (final course in _courses) {
      final grade = course['grade'] as String;
      if (gradePoints.containsKey(grade)) {
        final credits = course['credits'] as int;
        totalPoints += gradePoints[grade]! * credits;
        totalCredits += credits;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  void registerCourse({required String code, required String title, required int credits, required String faculty, required Color color}) {
    if (!_courses.any((c) => c['code'] == code)) {
      _courses.add({'code': code, 'title': title, 'credits': credits, 'faculty': faculty, 'color': color, 'marks': {'Internal': 0, 'Mid-term': 0, 'Target': 75}, 'notes': [], 'grade': 'N/A'});
      notifyListeners();
    }
  }

  void updateMarks(String courseCode, String type, int value) {
    final index = _courses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) {
      _courses[index]['marks'][type] = value;
      notifyListeners();
    }
  }

  void updateGrade(String courseCode, String grade) {
    final index = _courses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) {
      _courses[index]['grade'] = grade;
      notifyListeners();
    }
  }

  void addNote(String courseCode, String note) {
    final index = _courses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) {
      (_courses[index]['notes'] as List).add(note);
      notifyListeners();
    }
  }

  void addClassToTimetable(String day, String courseCode, String time, String location, double timeValue) {
    _weeklyTimetable[day]!.add({
      'id': _generateSlotId(),
      'time': time,
      'courseCode': courseCode,
      'location': location,
      'timeValue': timeValue,
    });
    _weeklyTimetable[day]!.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
    notifyListeners();
  }

  void editClassInTimetable(String day, String slotId, String courseCode, String time, String location, double timeValue) {
    final list = _weeklyTimetable[day]!;
    final index = list.indexWhere((s) => s['id'] == slotId);
    if (index != -1) {
      list[index] = {
        'id': slotId,
        'time': time,
        'courseCode': courseCode,
        'location': location,
        'timeValue': timeValue,
      };
      list.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
      notifyListeners();
    }
  }

  void deleteClassFromTimetable(String day, String slotId) {
    _weeklyTimetable[day]!.removeWhere((s) => s['id'] == slotId);
    notifyListeners();
  }

  void markAttendance(String dateKey, String slotId, bool isPresent) {
    if (!_attendanceRecord.containsKey(dateKey)) {
      _attendanceRecord[dateKey] = {};
    }
    _attendanceRecord[dateKey]![slotId] = isPresent;
    notifyListeners();
  }

  List<Map<String, dynamic>> getTimetableForDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String day = days[date.weekday - 1];
    final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    return _weeklyTimetable[day]!.map((slot) {
      final course = _courses.firstWhere((c) => c['code'] == slot['courseCode'], orElse: () => {'title': 'Unknown', 'color': Colors.grey});
      return {
        ...slot,
        'subject': course['title'],
        'color': course['color'],
        'attendance': _attendanceRecord[dateKey]?[slot['id']],
      };
    }).toList();
  }

  List<Map<String, dynamic>> getAttendanceHistory(String courseCode) {
    List<Map<String, dynamic>> history = [];
    DateTime current = semesterStart;
    DateTime end = semesterEnd.isBefore(DateTime.now()) ? semesterEnd : DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String day = days[current.weekday - 1];
      String dateKey = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      
      for (var slot in _weeklyTimetable[day]!) {
        if (slot['courseCode'] == courseCode) {
          history.add({
            'id': slot['id'],
            'date': dateKey,
            'time': slot['time'],
            'location': slot['location'],
            'status': _attendanceRecord[dateKey]?[slot['id']],
          });
        }
      }
      current = current.add(const Duration(days: 1));
    }
    return history.reversed.toList();
  }

  List<Map<String, dynamic>> getAttendanceStats() {
    Map<String, Map<String, int>> statsMap = {};
    for (var course in _courses) {
      statsMap[course['code']] = {'attended': 0, 'total': 0};
    }

    DateTime current = semesterStart;
    DateTime end = DateTime.now().isBefore(semesterEnd) ? DateTime.now() : semesterEnd;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String day = days[current.weekday - 1];
      String dateKey = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      
      for (var slot in _weeklyTimetable[day]!) {
        String code = slot['courseCode'];
        if (statsMap.containsKey(code)) {
          bool? status = _attendanceRecord[dateKey]?[slot['id']];
          if (status != null) {
            statsMap[code]!['total'] = statsMap[code]!['total']! + 1;
            if (status) {
              statsMap[code]!['attended'] = statsMap[code]!['attended']! + 1;
            }
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return _courses.map((course) {
      return {
        'code': course['code'],
        'class': course['title'],
        'attended': statsMap[course['code']]!['attended'],
        'total': statsMap[course['code']]!['total'],
        'color': course['color'],
      };
    }).toList();
  }

  void addTodo(String title, String courseCode) {
    _todoList.add({'title': title, 'isDone': false, 'courseCode': courseCode});
    notifyListeners();
  }

  void toggleTodo(int index) {
    if (index >= 0 && index < _todoList.length) {
      _todoList[index]['isDone'] = !_todoList[index]['isDone'];
      notifyListeners();
    }
  }

  void toggleEventRegistration(int eventId) {
    final index = _allEvents.indexWhere((e) => e['id'] == eventId);
    if (index != -1) {
      _allEvents[index]['isRegistered'] = !(_allEvents[index]['isRegistered'] as bool);
      notifyListeners();
    }
  }
}

final AcademicController academicController = AcademicController();
