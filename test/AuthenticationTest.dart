import 'package:flutter_test/flutter_test.dart';

/// Fake Authentication System (no DB)
class FakeAuthService {
  final Map<String, String> users = {};

  bool register(String username, String password) {
    if (username.isEmpty || password.length < 4) {
      return false;
    }

    if (users.containsKey(username)) {
      return false; // already exists
    }

    users[username] = password;
    return true;
  }

  bool login(String username, String password) {
    if (!users.containsKey(username)) return false;

    return users[username] == password;
  }
}

void main() {
  group('🔐 Fake Authentication Tests', () {
    late FakeAuthService auth;

    setUp(() {
      auth = FakeAuthService();
    });

    // ✅ Registration Success
    test('✅ Register user with valid credentials', () {
      print('Input -> username: sai, password: 1234');

      bool result = auth.register('sai', '1234');

      print('Output -> $result');

      expect(result, true);
    });

    // ❌ Registration Fail (short password)
    test('❌ Register should fail for short password', () {
      print('Input -> username: sai, password: 12');

      bool result = auth.register('sai', '12');

      expect(result, false);
    });

    // ❌ Registration Fail (duplicate user)
    test('❌ Duplicate user should not register', () {
      auth.register('sai', '1234');

      bool result = auth.register('sai', '1234');

      expect(result, false);
    });

    // ✅ Login Success
    test('✅ Login with correct credentials', () {
      auth.register('sai', '1234');

      bool result = auth.login('sai', '1234');

      expect(result, true);
    });

    // ❌ Login Fail (wrong password)
    test('❌ Login fails with wrong password', () {
      auth.register('sai', '1234');

      bool result = auth.login('sai', 'wrong');

      expect(result, false);
    });

    // ❌ Login Fail (user not found)
    test('❌ Login fails for unregistered user', () {
      bool result = auth.login('unknown', '1234');

      expect(result, false);
    });
  });
}