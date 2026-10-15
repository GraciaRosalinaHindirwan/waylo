
import 'package:password_guard/password_guard.dart';
import 'package:flutter/foundation.dart';

class PasswordHasher {
  static Future<String> hashPassword(String password) async {
    debugPrint('PH-1: Memanggil PasswordGuard.hash');
    final result = await PasswordGuard.hash(
      password: password,
      algorithm: PasswordAlgorithm.pbkdf2,
      config: PBKDF2Config(
        iterations: 100000,
        keyLength: 32,
      ),
    );
    debugPrint('PH-2: Hash berhasil dibuat');

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
