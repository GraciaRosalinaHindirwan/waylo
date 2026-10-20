
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricCredentials {
  static const _storage = FlutterSecureStorage();

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _storage.write(
      key: 'biometric_credentials',
      value: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
  }

  Future<Map<String, String>?> readCredentials() async {
    final value = await _storage.read(
      key: 'biometric_credentials',
    );

    if (value == null) return null;

    final data = jsonDecode(value) as Map<String, dynamic>;

    return {
      'username': data['username'] as String,
      'password': data['password'] as String,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'biometric_credentials');
  }
}
