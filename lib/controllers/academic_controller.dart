import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class AcademicController extends ChangeNotifier {
  bool isLoading = false;
  bool syncFailed = false;
  String? lastErrorMessage;
  int? currentStudentId;
  String? currentStudentName;

  DateTime semesterStart = DateTime(DateTime.now().year, 1, 1);
  DateTime semesterEnd = DateTime(DateTime.now().year, 12, 31);

  // Organizational Data (Remote)
  List<Map<String, dynamic>> _orgCourses = [];
  Map<String, List<Map<String, dynamic>>> _orgTimetableByDate = {};
  List<Map<String, dynamic>> _orgEvents = [];
  List<Map<String, dynamic>> _orgAssignments = [];
  Map<String, Map<String, bool>> _orgAttendanceRecord = {};

  // Personal Data (Local Only)
  List<Map<String, dynamic>> _personalCourses = [];
  Map<String, List<Map<String, dynamic>>> _personalTimetable = {
    'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': [],
  };
  List<Map<String, dynamic>> _todoList = [];
  Map<String, Map<String, bool>> _personalAttendanceRecord = {};

  // Combined Getters
  List<Map<String, dynamic>> get courses => [..._orgCourses, ..._personalCourses];
  List<Map<String, dynamic>> get todoList => _todoList;
  List<Map<String, dynamic>> get allEvents => _orgEvents;
  List<Map<String, dynamic>> get assignments => _orgAssignments;
  List<Map<String, dynamic>> get registeredEvents => _orgEvents.where((e) => e['isRegistered'] == true).toList();

  AcademicController() {
    // Basic init, loadLocalPersonalData is now student-specific and called after login/session check
  }

  // --- PERSISTENCE ---
  Future<void> _loadLocalPersonalData() async {
    if (currentStudentId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String prefix = "student_${currentStudentId}_";
    
    if (prefs.containsKey('${prefix}personal_courses')) {
      _personalCourses = List<Map<String, dynamic>>.from(json.decode(prefs.getString('${prefix}personal_courses')!));
    } else {
      _personalCourses = [];
    }
    
    if (prefs.containsKey('${prefix}personal_timetable')) {
      _personalTimetable = Map<String, List<Map<String, dynamic>>>.from(
        (json.decode(prefs.getString('${prefix}personal_timetable')!) as Map).map(
          (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))
        )
      );
    } else {
      _personalTimetable = {'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': []};
    }

    if (prefs.containsKey('${prefix}todo_list')) {
      _todoList = List<Map<String, dynamic>>.from(json.decode(prefs.getString('${prefix}todo_list')!));
    } else {
      _todoList = [];
    }

    if (prefs.containsKey('${prefix}personal_attendance_record')) {
      _personalAttendanceRecord = Map<String, Map<String, bool>>.from(
        (json.decode(prefs.getString('${prefix}personal_attendance_record')!) as Map).map(
          (k, v) => MapEntry(k, Map<String, bool>.from(v))
        )
      );
    } else {
      _personalAttendanceRecord = {};
    }
    notifyListeners();
  }

  Future<void> _savePersonalData() async {
    if (currentStudentId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String prefix = "student_${currentStudentId}_";
    
    await prefs.setString('${prefix}personal_courses', json.encode(_personalCourses));
    await prefs.setString('${prefix}personal_timetable', json.encode(_personalTimetable));
    await prefs.setString('${prefix}todo_list', json.encode(_todoList));
    await prefs.setString('${prefix}personal_attendance_record', json.encode(_personalAttendanceRecord));
  }

  // --- AUTH & SYNC ---
  
  Future<String?> signUp(String name, String email, String password, int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final existingUser = await DatabaseService().getStudentByEmail(email);
      if (existingUser != null) {
        isLoading = false;
        notifyListeners();
        return "Email already registered";
      }
      await DatabaseService().createStudent(id: id, name: name, email: email, password: password);
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> login(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final db = DatabaseService();
      final user = await db.getStudentByEmail(email);
      
      if (user == null) {
        isLoading = false;
        notifyListeners();
        return "User does not exist";
      }
      
      if (user['password'] != password) {
        isLoading = false;
        notifyListeners();
        return "Incorrect password";
      }

      final sessionId = const Uuid().v4();
      await db.updateSessionId(user['student_id'], sessionId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', sessionId);

      currentStudentId = user['student_id'] as int;
      currentStudentName = user['student_name'] as String;
      
      await _loadLocalPersonalData(); // Load data specific to THIS student
      await fetchOrganizationalData(context);
      
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Connection error: ${e.toString()}";
    }
  }

  Future<bool> loginWithSession(String sessionId, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final db = DatabaseService();
      final user = await db.getStudentBySessionId(sessionId);
      
      if (user != null) {
        currentStudentId = user['student_id'] as int;
        currentStudentName = user['student_name'] as String;
        await _loadLocalPersonalData(); // Load data specific to THIS student
        await fetchOrganizationalData(context);
        isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Session login failed: $e");
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    if (currentStudentId != null) {
      await DatabaseService().updateSessionId(currentStudentId!, null);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    currentStudentId = null;
    currentStudentName = null;
    _orgCourses = [];
    _orgTimetableByDate = {};
    _orgAttendanceRecord = {};
    _personalCourses = [];
    _personalTimetable = {'Monday': [], 'Tuesday': [], 'Wednesday': [], 'Thursday': [], 'Friday': [], 'Saturday': [], 'Sunday': []};
    _todoList = [];
    _personalAttendanceRecord = {};
    notifyListeners();
  }

  Future<void> fetchOrganizationalData(BuildContext context) async {
    if (currentStudentId == null) return;
    isLoading = true;
    syncFailed = false;
    notifyListeners();

    try {
      final db = DatabaseService();
      
      final rawCourses = await db.fetchOrgCourses(currentStudentId!);
      _orgCourses = rawCourses.map((c) => {
        'code': c['course_id'].toString(),
        'title': c['course_name'],
        'credits': c['credits'],
        'faculty': c['faculty_name'],
        'color': Colors.indigo.value,
        'marks': {'Internal': c['internal'] ?? 0, 'Mid-term': c['mid_term'] ?? 0, 'Target': 75},
        'grade': c['grade'] ?? 'N/A',
        'isPersonal': false,
        'no_of_classes': c['no_of_classes'] ?? 0,
      }).toList();

      final rawTimetable = await db.fetchTimetable(currentStudentId!);
      _orgTimetableByDate = {};
      for (var slot in rawTimetable) {
        DateTime date = slot['date'] as DateTime;
        String dateKey = _formatDateToKey(date);
        _orgTimetableByDate.putIfAbsent(dateKey, () => []).add({
          'id': slot['tt_id'].toString(),
          'time': "${slot['time']}:00",
          'courseCode': slot['course_id'].toString(),
          'location': 'Campus',
          'timeValue': (slot['time'] as int).toDouble(),
          'date': date,
          'isPersonal': false,
        });
      }

      final rawAtt = await db.fetchAttendance(currentStudentId!);
      _orgAttendanceRecord = {};
      for (var att in rawAtt) {
        DateTime dt = att['date'] as DateTime;
        String dateKey = _formatDateToKey(dt);
        String ttId = att['tt_id'].toString();
        _orgAttendanceRecord.putIfAbsent(dateKey, () => {})[ttId] = true;
      }

      final rawAllEvents = await db.fetchEvents();
      final rawMyEvents = await db.fetchRegisteredEvents(currentStudentId!);
      final myEventIds = rawMyEvents.map((e) => e['event_id']).toSet();
      _orgEvents = rawAllEvents.map((e) => {'id': e['event_id'], 'title': e['event_name'], 'date': e['start_date'].toString(), 'capacity': e['capacity'], 'isRegistered': myEventIds.contains(e['event_id'])}).toList();

      final rawAsm = await db.fetchAssignments(currentStudentId!);
      _orgAssignments = rawAsm.map((a) => {'id': a['assignment_id'].toString(), 'title': a['assignment_name'], 'description': a['description'], 'courseCode': a['course_id'].toString(), 'deadline': a['deadline'].toString()}).toList();

      syncFailed = false;
    } catch (e) {
      syncFailed = true;
      if (context.mounted) _showErrorPopup(context, "Database Sync Failed", e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 12), Expanded(child: Text(title))]),
        content: SingleChildScrollView(child: Text(message)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  // --- UTILS ---
  String _formatIntToTime(int hour) {
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String period = hour >= 12 ? 'PM' : 'AM';
    return "${displayHour.toString().padLeft(2, '0')}:00 $period";
  }

  String _formatDateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --- ACTIONS ---
  void toggleTodo(int index) {
    if (index >= 0 && index < _todoList.length) {
      _todoList[index]['isDone'] = !(_todoList[index]['isDone'] as bool);
      _savePersonalData(); notifyListeners();
    }
  }

  void addTodo(String title, String courseCode) {
    _todoList.add({'title': title, 'isDone': false, 'courseCode': courseCode});
    _savePersonalData(); notifyListeners();
  }

  void markAttendance(String dateKey, String slotId, bool isPresent) {
    bool isPersonal = false;
    for (var daySlots in _personalTimetable.values) {
      if (daySlots.any((s) => s['id'] == slotId)) { isPersonal = true; break; }
    }
    if (isPersonal) {
      if (isPresent) { _personalAttendanceRecord.putIfAbsent(dateKey, () => {})[slotId] = true; }
      else { _personalAttendanceRecord[dateKey]?.remove(slotId); }
      _savePersonalData(); notifyListeners();
    }
  }

  void registerPersonalCourse({required String code, required String title, required int credits, required Color color}) {
    _personalCourses.add({'code': code, 'title': title, 'credits': credits, 'faculty': 'Personal', 'color': color.value, 'marks': {'Total': 0}, 'notes': [], 'grade': 'N/A', 'isPersonal': true});
    _savePersonalData(); notifyListeners();
  }

  void addClassToTimetable(String day, String courseCode, String time, String location, double timeValue) {
    if (_personalTimetable.containsKey(day)) {
      _personalTimetable[day]!.add({'id': "p_${DateTime.now().microsecondsSinceEpoch}", 'time': time, 'courseCode': courseCode, 'location': location, 'timeValue': timeValue, 'isPersonal': true});
      _personalTimetable[day]!.sort((a, b) => (a['timeValue'] as double).compareTo(b['timeValue'] as double));
      _savePersonalData(); notifyListeners();
    }
  }

  void editClassInTimetable(String day, String slotId, String courseCode, String time, String location, double timeValue) {
    if (_personalTimetable.containsKey(day)) {
      final list = _personalTimetable[day]!;
      final index = list.indexWhere((s) => s['id'] == slotId);
      if (index != -1) {
        list[index] = {'id': slotId, 'time': time, 'courseCode': courseCode, 'location': location, 'timeValue': timeValue, 'isPersonal': true};
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

  void updateMarks(String courseCode, String type, int value) {
    int index = _personalCourses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) { _personalCourses[index]['marks'][type] = value; _savePersonalData(); }
    notifyListeners();
  }

  void updateGrade(String courseCode, String grade) {
    int index = _personalCourses.indexWhere((c) => c['code'] == courseCode);
    if (index != -1) { _personalCourses[index]['grade'] = grade; _savePersonalData(); }
    notifyListeners();
  }

  void createAssignment({required String title, required String description, required String courseCode, required DateTime deadline}) {
    _orgAssignments.add({'id': "asm_${DateTime.now().microsecondsSinceEpoch}", 'title': title, 'description': description, 'courseCode': courseCode, 'deadline': deadline.toIso8601String()});
    notifyListeners();
  }

  void extendAssignmentDeadline(String assignmentId, DateTime newDeadline) {
    final index = _orgAssignments.indexWhere((a) => a['id'] == assignmentId);
    if (index != -1) { _orgAssignments[index]['deadline'] = newDeadline.toIso8601String(); notifyListeners(); }
  }

  void toggleEventRegistration(int eventId) {
    final index = _orgEvents.indexWhere((e) => e['id'] == eventId);
    if (index != -1) { _orgEvents[index]['isRegistered'] = !(_orgEvents[index]['isRegistered'] as bool? ?? false); notifyListeners(); }
  }

  // --- QUERY LOGIC ---
  List<Map<String, dynamic>> getTimetableForDate(DateTime date) {
    String dateKey = _formatDateToKey(date);
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String dayName = days[date.weekday - 1];
    List<Map<String, dynamic>> combinedSlots = [...(_orgTimetableByDate[dateKey] ?? []), ...(_personalTimetable[dayName] ?? [])];
    return combinedSlots.map((slot) {
      final course = courses.firstWhere((c) => c['code'] == slot['courseCode'], orElse: () => {'title': 'Unknown', 'color': Colors.grey.value});
      bool? markedStatus;
      if (slot['isPersonal'] == true) { markedStatus = _personalAttendanceRecord[dateKey]?[slot['id']]; }
      else { markedStatus = _orgAttendanceRecord[dateKey]?[slot['id']] ?? false; }
      return {...slot, 'subject': course['title'], 'color': Color(course['color'] as int), 'attendance': markedStatus};
    }).toList();
  }

  List<Map<String, dynamic>> getAttendanceStats() {
    Map<String, Map<String, int>> statsMap = {};
    Map<String, int> personalStudyHours = {}; 
    for (var course in courses) { statsMap[course['code']] = {'attended': 0, 'total': 0}; personalStudyHours[course['code']] = 0; }
    _orgTimetableByDate.forEach((date, slots) {
      DateTime dt = DateTime.parse(date);
      if (dt.isBefore(DateTime.now()) || dt.isAtSameMomentAs(DateTime.now())) {
        for (var slot in slots) {
          String code = slot['courseCode'];
          if (statsMap.containsKey(code)) {
            statsMap[code]!['total'] = statsMap[code]!['total']! + 1;
            if (_orgAttendanceRecord[date]?[slot['id']] == true) { statsMap[code]!['attended'] = statsMap[code]!['attended']! + 1; }
          }
        }
      }
    });
    _personalAttendanceRecord.forEach((date, slots) {
      slots.forEach((ttId, present) {
        if (present) {
          String code = "unknown";
          for (var daySlots in _personalTimetable.values) {
            final s = daySlots.firstWhere((slot) => slot['id'] == ttId, orElse: () => {});
            if (s.isNotEmpty) { code = s['courseCode']; break; }
          }
          if (personalStudyHours.containsKey(code)) { personalStudyHours[code] = personalStudyHours[code]! + 1; }
        }
      });
    });
    return courses.map((course) {
      final code = course['code'];
      return {'code': code, 'class': course['title'], 'attended': statsMap[code]!['attended'], 'total': statsMap[code]!['total'], 'personalHours': personalStudyHours[code], 'color': Color(course['color'] as int), 'isPersonal': course['isPersonal'] ?? false};
    }).toList();
  }

  List<Map<String, dynamic>> getAttendanceHistory(String courseCode) {
    List<Map<String, dynamic>> history = [];
    _orgTimetableByDate.forEach((date, slots) {
      for (var slot in slots) {
        if (slot['courseCode'] == courseCode) {
          bool isPresent = _orgAttendanceRecord[date]?[slot['id']] ?? false;
          history.add({'id': slot['id'], 'date': date, 'time': slot['time'], 'location': slot['location'], 'status': isPresent, 'type': 'Official'});
        }
      }
    });
    _personalAttendanceRecord.forEach((date, slots) {
      slots.forEach((ttId, present) {
        Map<String, dynamic> slotData = {};
        for (var daySlots in _personalTimetable.values) {
          final s = daySlots.firstWhere((slot) => slot['id'] == ttId && slot['courseCode'] == courseCode, orElse: () => {});
          if (s.isNotEmpty) { slotData = s; break; }
        }
        if (slotData.isNotEmpty) {
          history.add({'id': ttId, 'date': date, 'time': slotData['time'], 'location': slotData['location'], 'status': present, 'type': 'Personal Study'});
        }
      });
    });
    return history.reversed.toList();
  }

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
}

final AcademicController academicController = AcademicController();
