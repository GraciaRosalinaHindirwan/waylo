import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waylo/service/password_hasher.dart';

// untuk menyimpan profil yang bisa dibaca saat offline

class OfflineAuthStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _usernameKey = 'offline_auth_username';
  static const String _userIdKey = 'offline_auth_user_id';
  static const String _passwordHashKey = 'offline_auth_password_hash';

  // Simpan verifier lokal setelah login online berhasil.
  // Password asli tidak disimpan oleh service ini.
  Future<void> saveCredentials({
    required int userId,
    required String username,
    required String password,
  }) async {
    final passwordHash =
        await PasswordHasher.hashPassword(password);

    await _storage.write(
      key: _usernameKey,
      value: username.trim().toLowerCase(),
    );

    await _storage.write(
      key: _userIdKey,
      value: userId.toString(),
    );

    await _storage.write(
      key: _passwordHashKey,
      value: passwordHash,
    );
  }

  // Verifikasi username dan password ketika offline.
  Future<int?> verifyCredentials({
    required String username,
    required String password,
  }) async {
    final savedUsername = await _storage.read(key: _usernameKey);
    final savedUserId = await _storage.read(key: _userIdKey);
    final savedHash = await _storage.read(key: _passwordHashKey);

    if (savedUsername == null ||
        savedUserId == null ||
        savedHash == null) {
      return null;
    }

    if (username.trim().toLowerCase() != savedUsername) {
      return null;
    }

    final isValid = await PasswordHasher.verifyPassword(
      password: password,
      hashedPassword: savedHash,
    );

    if (!isValid) return null;

    return int.tryParse(savedUserId);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _passwordHashKey);
  }
}
