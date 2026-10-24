
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waylo/models/user.dart';

//untuk menyimpan profil yang bisa dibaca saat offline.

class OfflineUserStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _userKey = 'offline_cached_user';

  Future<void> saveUser(User user) async {
    final data = {
      'id': user.id,
      'fullname': user.fullname,
      'username': user.username,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'hasCompletedPreference': user.hasCompletedPreference,
      'profileImageBase64': user.profileImageBase64,
    };

    await _storage.write(
      key: _userKey,
      value: jsonEncode(data),
    );
  }

  Future<User?> getUser() async {
    final value = await _storage.read(key: _userKey);

    if (value == null) return null;

    try {
      final data = jsonDecode(value) as Map<String, dynamic>;

      return User(
        id: (data['id'] as num).toInt(),
        fullname: data['fullname'] as String? ?? '',
        username: data['username'] as String? ?? '',
        password: '',
        districts: const [],
        categories: const [],
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
        hasCompletedPreference:
            data['hasCompletedPreference'] as bool? ?? false,
        profileImageBase64: data['profileImageBase64'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}
