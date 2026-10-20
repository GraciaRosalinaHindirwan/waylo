import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricCredentials {
  static const _usernameKey = 'biometric_username';
  static const _passwordKey = 'biometric_password';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(
    aOptions: AndroidOptions.biometric(
      enforceBiometrics: true,
      biometricPromptTitle: 'Aktifkan login fingerprint WAYLO',
      biometricPromptSubtitle:
          'Verifikasi untuk mengakses kredensial login',
    ),
  );

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await _storage.write(
      key: _usernameKey,
      value: username,
    );

    await _storage.write(
      key: _passwordKey,
      value: password,
    );
  }

  Future<Map<String, String>?> readCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);

    if (username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }

    return {
      'username': username,
      'password': password,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}