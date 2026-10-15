
import 'package:password_guard/password_guard.dart';

class PasswordHasher {
  static Future<String> hashPassword(String password) async {
    final result = await PasswordGuard.hash(
      password: password,
    );

    return result.hash;
  }

  static Future<bool> verifyPassword({
    required String password, //password asli 
    required String hashedPassword, //password yang di hash 
  }) async {
    return PasswordGuard.verify(
      password: password,
      hash: hashedPassword,
    );
  }
}
