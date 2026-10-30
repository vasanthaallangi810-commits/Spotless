import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Tests', () {
    test('Email validation should accept a valid email', () {
      String email = 'test@gmail.com';

      expect(email.contains('@'), true);
    });

    test('Password should not be empty', () {
      String password = '123456';

      expect(password.isNotEmpty, true);
    });

    test('Login details should be valid', () {
      String email = 'test@gmail.com';
      String password = '123456';

      bool isValid = email.isNotEmpty &&
          email.contains('@') &&
          password.isNotEmpty;

      expect(isValid, true);
    });
  });
}
