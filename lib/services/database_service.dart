import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;

  Future<Connection> get connection async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }
    _connection = await _connect();
    return _connection!;
  }

  Future<Connection> _connect() async {
    // Note: Use '10.0.2.2' for Android Emulator to connect to localhost on the host machine.
    // Use the machine IP for physical devices.
    String host = 'localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = '10.0.2.2';
    }

    try {
      final conn = await Connection.open(
        Endpoint(
          host: host,
          port: 5000,
          database: 'iams',
          username: 'postgres',
          password: 'higoogle6457',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
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
  Future<Map<String, dynamic>?> authenticateStudent(String email, String password) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM students WHERE email = @email AND password = @password'),
      parameters: {'email': email, 'password': password},
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final columns = result.schema.columns;
    final map = <String, dynamic>{};
    for (var i = 0; i < columns.length; i++) {
      map[columns[i].columnName] = row[i];
    }
    return map;
  }

  // --- Data Fetching ---
  Future<List<Map<String, dynamic>>> fetchOrgCourses(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT c.*, r.grade, r.marks, r.state 
        FROM courses c
        JOIN registrations r ON c.course_id = r.course_id
        WHERE r.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        map[result.schema.columns[i].columnName] = row[i];
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
        map[result.schema.columns[i].columnName] = row[i];
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
        map[result.schema.columns[i].columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRegisteredEvents(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('''
        SELECT e.* 
        FROM events e
        JOIN event_registrations er ON e.event_id = er.event_id
        WHERE er.student_id = @studentId
      '''),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        map[result.schema.columns[i].columnName] = row[i];
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
        map[result.schema.columns[i].columnName] = row[i];
      }
      return map;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAttendance(int studentId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM attendance WHERE student_id = @studentId'),
      parameters: {'studentId': studentId},
    );

    return result.map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < result.schema.columns.length; i++) {
        map[result.schema.columns[i].columnName] = row[i];
      }
      return map;
    }).toList();
  }
}
