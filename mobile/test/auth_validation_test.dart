import 'package:flutter_test/flutter_test.dart';

void main() {
  bool isValidLogin(String identifier, String password) {
    return identifier.trim().isNotEmpty && password.isNotEmpty;
  }

  bool isValidRegister({
    required String username,
    required String email,
    required String password,
    required String confirm,
  }) {
    return username.length >= 3 &&
        email.contains('@') &&
        password.length >= 8 &&
        password == confirm;
  }

  test('login validation requires both fields', () {
    expect(isValidLogin('', 'password'), false);
    expect(isValidLogin('user', ''), false);
    expect(isValidLogin('user', 'pass'), true);
  });

  test('register validation rules', () {
    expect(
      isValidRegister(
        username: 'ab',
        email: 'a@b.com',
        password: '12345678',
        confirm: '12345678',
      ),
      false,
    );
    expect(
      isValidRegister(
        username: 'milo_cat',
        email: 'milo@example.com',
        password: 'demo12345',
        confirm: 'demo12345',
      ),
      true,
    );
  });
}
