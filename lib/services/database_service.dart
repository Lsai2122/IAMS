import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;

  Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }
    _connection = await _connect();
    return _connection!;
  }

  Future<Connection> _connect() async {
    // Host provided by user
    String host = '192.168.137.1';
    
    // For local development on web or desktop, localhost might be needed
    if (kIsWeb) host = 'localhost';

    try {
      final conn = await Connection.open(
        Endpoint(
          host: host,
          port: 5000,
          database: 'iams',
          username: 'postgres',
          password: 'higoogle6457',
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      return conn;
    } catch (e) {
      debugPrint('Database connection error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // --- Authentication ---
  
  Future<Map<String, dynamic>?> getStudentByEmail(String email) async {
    try {
      final conn = await connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM students WHERE email = @email'),
        parameters: {'email': email},
      );

      if (result.isEmpty) return null;

      final row = result.first;
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) {
          map[columnName] = row[i];
        }
      }
      return map;
    } catch (e) {
      debugPrint('Error getting student: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getStudentBySessionId(String sessionId) async {
    try {
      final conn = await connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM students WHERE session_id = @sessionId'),
        parameters: {'sessionId': sessionId},
      );

      if (result.isEmpty) return null;
      final row = result.first;
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSessionId(int studentId, String? sessionId) async {
    final conn = await connection;
    await conn.execute(
      Sql.named('UPDATE students SET session_id = @sessionId WHERE student_id = @studentId'),
      parameters: {'sessionId': sessionId, 'studentId': studentId},
    );
  }

  Future<void> createStudent({required int id, required String name, required String email, required String password}) async {
    final conn = await connection;
    await conn.execute(
      Sql.named('INSERT INTO students (student_id, student_name, email, password) VALUES (@id, @name, @email, @password)'),
      parameters: {'id': id, 'name': name, 'email': email, 'password': password},
    );
  }

  // --- Data Fetching ---
  
  Future<List<Map<String, dynamic>>> fetchOrgCourses(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT c.*, r.grade, r.internal, r.mid_term, r.state 
        FROM courses c
        JOIN registrations r ON c.course_id = r.course_id
        WHERE r.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTimetable(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT t.*, c.course_name, c.credits, c.faculty_name
        FROM timetable t
        JOIN courses c ON t.course_id = c.course_id
        JOIN registrations r ON c.course_id = r.course_id
        WHERE r.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAttendance(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT a.*, t.date 
        FROM attendance a 
        JOIN timetable t ON a.tt_id = t.tt_id 
        WHERE a.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final conn = await connection;
    final result = await conn.execute('SELECT * FROM events');
    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredEvents(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM event_registrations WHERE student_id = @studentId'),
      parameters: {'studentId': studentId},
    );
    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAssignments(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT a.*, c.course_name
        FROM assignments a
        JOIN courses c ON a.course_id = c.course_id
        JOIN registrations r ON c.course_id = r.course_id
        WHERE r.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );
    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        final columnName = result.schema.columns[i].columnName;
        if (columnName != null) map[columnName] = row[i];
      }
      return map;
    }).toList();
  }
}
