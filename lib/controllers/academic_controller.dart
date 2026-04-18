import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class AcademicController extends ChangeNotifier {
  bool isLoading = false;
  bool syncFailed = false;
  String? lastErrorMessage;

  // Semester Boundaries
  DateTime semesterStart = DateTime(DateTime.now().year, 1, 1);
  DateTime semesterEnd = DateTime(DateTime.now().year, 12, 31);

  // --- ORGANIZATIONAL DATA (Remote/Cached) ---
  List<Map<String, dynamic>> _orgCourses = [];
  Map<String, List<Map<String, dynamic>>> _orgTimetable = {
    'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': [],
  };
  List<Map<String, dynamic>> _orgEvents = [];
  List<Map<String, dynamic>> _orgAssignments = [];

  // --- PERSONAL DATA (Device-Only) ---
  List<Map<String, dynamic>> _personalCourses = [];
  Map<String, List<Map<String, dynamic>>> _personalTimetable = {
    'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': [],
  };
  List<Map<String, dynamic>> _todoList = [];
  Map<String, Map<String, bool>> _attendanceRecord = {};

  // Getters
  List<Map<String, dynamic>> get courses => [..._orgCourses, ..._personalCourses];
  List<Map<String, dynamic>> get todoList => _todoList;
  List<Map<String, dynamic>> get allEvents => _orgEvents;
  List<Map<String, dynamic>> get assignments => _orgAssignments;
  List<Map<String, dynamic>> get notifications => []; 
  List<Map<String, dynamic>> get registeredEvents => _orgEvents.where((e) => e['isRegistered'] == true).toList();

  double get gpa {
    final gradePoints = {'O': 10.0, 'A+': 9.0, 'A': 8.0, 'B+': 7.0, 'B': 6.0, 'C': 5.0, 'P': 4.0, 'F': 0.0};
    double totalPoints = 0;
    int totalCredits = 0;
    for (final course in courses) {
      final grade = course['grade'] as String? ?? 'N/A';
      if (gradePoints.containsKey(grade)) {
        final credits = course['credits'] as int? ?? 0;
        totalPoints += gradePoints[grade]! * credits;
        totalCredits += credits;
      }
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  AcademicController() {
    _init();
  }

  Future<void> _init() async {
    await _loadLocalData();
  }

  // --- PERSISTENCE LOGIC ---

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('personal_courses')) {
      _personalCourses = List<Map<String, dynamic>>.from(json.decode(prefs.getString('personal_courses')!));
    }
    if (prefs.containsKey('personal_timetable')) {
      _personalTimetable = Map<String, List<Map<String, dynamic>>>.from(
        (json.decode(prefs.getString('personal_timetable')!) as Map).map(
          (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))
        )
      );
    }
    if (prefs.containsKey('todo_list')) {
      _todoList = List<Map<String, dynamic>>.from(json.decode(prefs.getString('todo_list')!));
    }
    if (prefs.containsKey('attendance_record')) {
      _attendanceRecord = Map<String, Map<String, bool>>.from(
        (json.decode(prefs.getString('attendance_record')!) as Map).map(
          (k, v) => MapEntry(k, Map<String, bool>.from(v))
        )
      );
    }

    if (prefs.containsKey('cached_org_courses')) {
      _orgCourses = List<Map<String, dynamic>>.from(json.decode(prefs.getString('cached_org_courses')!));
    }
    if (prefs.containsKey('cached_org_timetable')) {
      _orgTimetable = Map<String, List<Map<String, dynamic>>>.from(
        (json.decode(prefs.getString('cached_org_timetable')!) as Map).map(
          (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))
        )
      );
    }
    if (prefs.containsKey('cached_org_assignments')) {
      _orgAssignments = List<Map<String, dynamic>>.from(json.decode(prefs.getString('cached_org_assignments')!));
    }
    
    notifyListeners();
  }

  Future<void> _savePersonalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_courses', json.encode(_personalCourses));
    await prefs.setString('personal_timetable', json.encode(_personalTimetable));
    await prefs.setString('todo_list', json.encode(_todoList));
    await prefs.setString('attendance_record', json.encode(_attendanceRecord));
  }

  Future<void> _cacheOrgData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_org_courses', json.encode(_orgCourses));
    await prefs.setString('cached_org_timetable', json.encode(_orgTimetable));
    await prefs.setString('cached_org_assignments', json.encode(_orgAssignments));
  }

  // --- SYNC LOGIC ---

  Future<void> fetchOrganizationalData(BuildContext context) async {
    isLoading = true;
    syncFailed = false;
    lastErrorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); 
      
      // Simulate real fetch to localhost
      // For now, returning actual data if you were connected.
      // throw const SocketException("Failed to connect to PostgreSQL server at localhost:5432.");

      _orgCourses = [
        {'code': 'CS301', 'title': 'Database Systems', 'credits': 4, 'faculty': 'Dr. Rao', 'color': Colors.blue.value, 'marks': {'Internal': 22, 'Mid-term': 45, 'Target': 90}, 'notes': ['Introduction to RDBMS'], 'grade': 'A', 'isPersonal': false},
        {'code': 'MA201', 'title': 'Engineering Math', 'credits': 3, 'faculty': 'Dr. Patel', 'color': Colors.orange.value, 'marks': {'Internal': 18, 'Mid-term': 38, 'Target': 85}, 'notes': ['Calculus basics'], 'grade': 'B+', 'isPersonal': false},
      ];

      _orgTimetable = {
        'Monday': [
          {'id': 'o1', 'time': '09:00 AM', 'courseCode': 'CS301', 'location': 'Hall 102', 'timeValue': 9.0},
          {'id': 'o2', 'time': '11:00 AM', 'courseCode': 'MA201', 'location': 'Room 405', 'timeValue': 11.0},
        ],
        'Tuesday': [
          {'id': 'o3', 'time': '01:00 PM', 'courseCode': 'CS401', 'location': 'Hall 201', 'timeValue': 13.0},
        ],
        'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': [],
      };

      await _cacheOrgData();
    } catch (e) {
      syncFailed = true;
      lastErrorMessage = e is SocketException 
          ? "Database Connection Error: ${e.message}" 
          : "Sync Error: ${e.toString()}";
          
      if (context.mounted) {
        _showErrorPopup(context, "Database Unreachable", lastErrorMessage!);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.dns_outlined, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  // --- ACTIONS ---

  void registerPersonalCourse({required String code, required String title, required int credits, required Color color}) {
    _personalCourses.add({
      'code': code, 'title': title, 'credits': credits, 'faculty': 'Personal', 
      'color': color.value, 'marks': {'Internal': 0, 'Mid-term': 0, 'Target': 75}, 'notes': [], 'grade': 'N/A', 'isPersonal': true
    });
    _savePersonalData();
    notifyListeners();
  }

  // FACULTY ACTION: Teachers mark attendance for students (updates the same record)
  void markAttendance(String dateKey, String slotId, bool isPresent) {
    if (!_attendanceRecord.containsKey(dateKey)) _attendanceRecord[dateKey] = {};
    _attendanceRecord[dateKey]![slotId] = isPresent;
    _savePersonalData();
    notifyListeners();
  }

  void updateMarks(String courseCode, String type, int value) {
    int index = _personalCourses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) {
      _personalCourses[index]['marks'][type] = value;
      _savePersonalData();
    } else {
      index = _orgCourses.indexWhere((c) => c['code'] == courseCode);
      if (index != -1) _orgCourses[index]['marks'][type] = value;
    }
    notifyListeners();
  }

  void updateGrade(String courseCode, String grade) {
    int index = _personalCourses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) {
      _personalCourses[index]['grade'] = grade;
      _savePersonalData();
    } else {
      index = _orgCourses.indexWhere((c) => c['code'] == courseCode);
      if (index != -1) _orgCourses[index]['grade'] = grade;
    }
    notifyListeners();
  }

  // FACULTY ACTION: Create Assignments
  void createAssignment({required String title, required String description, required String courseCode, required DateTime deadline}) {
    _orgAssignments.add({
      'id': "asm_${DateTime.now().microsecondsSinceEpoch}",
      'title': title,
      'description': description,
      'courseCode': courseCode,
      'deadline': deadline.toIso8601String(),
    });
    _cacheOrgData();
    notifyListeners();
  }

  void extendAssignmentDeadline(String assignmentId, DateTime newDeadline) {
    final index = _orgAssignments.indexWhere((a) => a['id'] == assignmentId);
    if (index != -1) {
      _orgAssignments[index]['deadline'] = newDeadline.toIso8601String();
      _cacheOrgData();
      notifyListeners();
    }
  }

  void addClassToTimetable(String day, String courseCode, String time, String location, double timeValue) {
    if (_personalTimetable.containsKey(day)) {
      _personalTimetable[day]!.add({
        'id': "p_${DateTime.now().microsecondsSinceEpoch}",
        'time': time,
        'courseCode': courseCode,
        'location': location,
        'timeValue': timeValue,
      });
      _personalTimetable[day]!.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
      _savePersonalData();
      notifyListeners();
    }
  }

  void editClassInTimetable(String day, String slotId, String courseCode, String time, String location, double timeValue) {
    if (_personalTimetable.containsKey(day)) {
      final list = _personalTimetable[day]!;
      final index = list.indexWhere((s) => s['id'] == slotId);
      if (index != -1) {
        list[index] = {'id': slotId, 'time': time, 'courseCode': courseCode, 'location': location, 'timeValue': timeValue};
        list.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
        _savePersonalData();
        notifyListeners();
      }
    }
  }

  void deleteClassFromTimetable(String day, String slotId) {
    if (_personalTimetable.containsKey(day)) {
      _personalTimetable[day]!.removeWhere((s) => s['id'] == slotId);
      _savePersonalData();
      notifyListeners();
    }
  }

  // --- QUERY LOGIC ---

  List<Map<String, dynamic>> getTimetableForDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String dayName = days[date.weekday - 1];
    String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> combinedSlots = [
      ...(_orgTimetable[dayName] ?? []),
      ...(_personalTimetable[dayName] ?? []),
    ];

    return combinedSlots.map((slot) {
      final course = courses.firstWhere(
        (c) => c['code'] == slot['courseCode'], 
        orElse: () => {'title': 'Unknown', 'color': Colors.grey.value}
      );
      bool isPersonal = (course['isPersonal'] ?? false);

      return {
        ...slot,
        'subject': course['title'] ?? 'Unknown',
        'color': Color(course['color'] as int? ?? Colors.grey.value),
        'attendance': _attendanceRecord[dateKey]?[slot['id']],
        'isPersonal': isPersonal,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getAttendanceStats() {
    Map<String, Map<String, int>> statsMap = {};
    for (var course in courses) {
      final code = course['code'] as String?;
      if (code != null) statsMap[code] = {'attended': 0, 'total': 0};
    }

    DateTime current = semesterStart;
    DateTime end = DateTime.now().isBefore(semesterEnd) ? DateTime.now() : semesterEnd;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String day = days[current.weekday - 1];
      String dateKey = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      
      List<Map<String, dynamic>> slots = [...(_orgTimetable[day] ?? []), ...(_personalTimetable[day] ?? [])];

      for (var slot in slots) {
        String? code = slot['courseCode'] as String?;
        if (code != null && statsMap.containsKey(code)) {
          bool? status = _attendanceRecord[dateKey]?[slot['id']];
          if (status != null) {
            statsMap[code]!['total'] = statsMap[code]!['total']! + 1;
            if (status) statsMap[code]!['attended'] = statsMap[code]!['attended']! + 1;
          }
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return courses.map((course) {
      final code = course['code'] as String? ?? '';
      return {
        'code': code,
        'class': course['title'] ?? 'Unknown',
        'attended': statsMap[code]?['attended'] ?? 0,
        'total': statsMap[code]?['total'] ?? 0,
        'color': Color(course['color'] as int? ?? Colors.grey.value),
      };
    }).toList();
  }

  List<Map<String, dynamic>> getAttendanceHistory(String courseCode) {
    List<Map<String, dynamic>> history = [];
    DateTime current = semesterStart;
    DateTime end = DateTime.now().isBefore(semesterEnd) ? DateTime.now() : semesterEnd;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String day = days[current.weekday - 1];
      String dateKey = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      
      List<Map<String, dynamic>> slots = [...(_orgTimetable[day] ?? []), ...(_personalTimetable[day] ?? [])];

      for (var slot in slots) {
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
  
  void addTodo(String title, String courseCode) {
    _todoList.add({'title': title, 'isDone': false, 'courseCode': courseCode});
    _savePersonalData();
    notifyListeners();
  }

  void toggleTodo(int index) {
    if (index >= 0 && index < _todoList.length) {
      _todoList[index]['isDone'] = !(_todoList[index]['isDone'] as bool? ?? false);
      _savePersonalData();
      notifyListeners();
    }
  }

  void toggleEventRegistration(int eventId) {
    final index = _orgEvents.indexWhere((e) => e['id'] == eventId);
    if (index != -1) {
      _orgEvents[index]['isRegistered'] = !(_orgEvents[index]['isRegistered'] as bool? ?? false);
      notifyListeners();
    }
  }
}

final AcademicController academicController = AcademicController();
