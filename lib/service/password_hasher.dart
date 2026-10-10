import 'package:password_guard/password_guard.dart';

class PasswordHasher {
  static Future<String> hashPassword(String password) async {
    final result = await PasswordGuard.hash(
      password: password,
    );

    return result.hash;
  }
}