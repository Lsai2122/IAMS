import 'package:flutter_test/flutter_test.dart';

/// 🧠 Mock Authentication Logic for Automated Testing
/// This class bypasses the real PostgreSQL database to allow 
/// headless testing in Bitrise CI environments.
class FakeAuthService {
  // Simple in-memory storage for test users: Email -> {id, name, password}
  final Map<String, Map<String, dynamic>> _mockDb = {};

  /// Validates input and registers a user if they don't already exist.
  Future<String?> signUp({
    required int id,
    required String name,
    required String email,
    required String password,
  }) async {
    // 🛑 Logic Rule 1: No empty fields allowed
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      return "All fields are required";
    }

    // 🛑 Logic Rule 2: ID must be a positive integer
    if (id <= 0) {
      return "Invalid Student ID";
    }

    // 🛑 Logic Rule 3: No duplicate emails
    if (_mockDb.containsKey(email)) {
      return "Email already registered";
    }

    // ✅ Success: Store in mock database
    _mockDb[email] = {
      'id': id,
      'name': name,
      'password': password,
    };
    return null; // Null means success
  }

  /// Verifies credentials against the mock database.
  Future<String?> login(String email, String password) async {
    // 🛑 Logic Rule 4: User must exist
    if (!_mockDb.containsKey(email)) {
      return "User does not exist";
    }

    // 🛑 Logic Rule 5: Password must match
    if (_mockDb[email]!['password'] != password) {
      return "Incorrect password";
    }

    // ✅ Success
    return null;
  }

  /// Utility for tests to clear data
  void clear() => _mockDb.clear();
}

void main() {
  group('🔐Authentication Integrated Workflow', () {
    late FakeAuthService auth;

    setUp(() {
      auth = FakeAuthService();
    });

    test('✅ SUCCESS: Create account and login with valid data', () async {
      print('Scenario: Valid user registration and login');
      
      // 1. Sign Up
      final regResult = await auth.signUp(
        id: 2021001,
        name: 'Sai Kiran',
        email: 'sai@college.edu',
        password: 'securePassword123'
      );
      expect(regResult, null);

      // 2. Login
      final loginResult = await auth.login('sai@college.edu', 'securePassword123');
      expect(loginResult, null);
      
      print('Result: Passed');
    });

    test('❌ FAIL: Prevent registration with empty fields', () async {
      print('Scenario: Missing name field');
      
      final result = await auth.signUp(
        id: 2021002,
        name: '',
        email: 'fail@college.edu',
        password: 'pass'
      );
      
      expect(result, "All fields are required");
      print('Result: Correctly Blocked');
    });

    test('❌ FAIL: Prevent login with incorrect password', () async {
      print('Scenario: Wrong password attempt');
      
      await auth.signUp(
        id: 2021003,
        name: 'John Doe',
        email: 'john@college.edu',
        password: 'correctPassword'
      );

      final result = await auth.login('john@college.edu', 'wrongPassword');
      
      expect(result, "Incorrect password");
      print('Result: Correctly Blocked');
    });

    test('❌ FAIL: Prevent login for non-existent user', () async {
      print('Scenario: Unregistered email login');
      
      final result = await auth.login('unknown@college.edu', 'somePass');
      
      expect(result, "User does not exist");
      print('Result: Correctly Blocked');
    });

    test('❌ FAIL: Handle invalid Student ID', () async {
      print('Scenario: Negative ID value');
      
      final result = await auth.signUp(
        id: -1,
        name: 'Bad ID',
        email: 'badid@college.edu',
        password: 'pass'
      );
      
      expect(result, "Invalid Student ID");
      print('Result: Correctly Blocked');
    });
  });
}
