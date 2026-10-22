
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user/user_repository.dart';
import 'package:waylo/service/password_hasher.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:waylo/service/biometric_credentials.dart';

class AuthService extends ChangeNotifier {
  final UserRepository repository;
  final SessionStorage sessionStorage;

  final BiometricCredentials biometricCredentials =
      BiometricCredentials();

  User? _currentUser;

  User? get currentUser => _currentUser;

  Uint8List? get profileImageBytes {
    final base64Image = _currentUser?.profileImageBase64;

    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64Image);
    } catch (e) {
      debugPrint('Gagal membaca foto profil: $e');
      return null;
    }
  }

  bool get isLoggedIn => _currentUser != null;

  AuthService(this.repository, this.sessionStorage);

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Simpan foto profil ke database dan perbarui user aktif.
  Future<void> setProfileImage(Uint8List bytes) async {
    final user = _currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final updatedUser = await repository.updateUser(
      User(
        id: user.id,
        fullname: user.fullname,
        username: user.username,
        password: user.password,
        districts: user.districts,
        categories: user.categories,
        hasCompletedPreference: user.hasCompletedPreference,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
        profileImageBase64: base64Encode(bytes),
      ),
    );

    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<User> register(User user) async {
    final response = await Supabase.instance.client.functions.invoke(
      'auth-user',
      body: {
        'action': 'register',
        'fullname': user.fullname,
        'username': user.username,
        'password': user.password,
      },
    );

    final data = response.data;

    if (response.status != 201 ||
        data is! Map ||
        data['user'] is! Map) {
      final message =
          data is Map && data['error'] is String
              ? data['error'] as String
              : 'Registrasi gagal';

      throw Exception(message);
    }

    final row = Map<String, dynamic>.from(data['user'] as Map);
    return _mapFunctionUser(row);
  }

  Future<void> enableBiometricLogin({
    required int userId,
    required String username,
    required String password,
  }) async {
    await biometricCredentials.saveCredentials(
      username: username,
      password: password,
    );

    await sessionStorage.saveBiometricUserId(userId);
  }

  Future<User> loginWithBiometric() async {
    final credentials =
        await biometricCredentials.readCredentials();

    if (credentials == null) {
      throw Exception(
        'Login fingerprint belum diaktifkan. '
        'Silakan login menggunakan username dan password.',
      );
    }

    return login(
      credentials['username']!,
      credentials['password']!,
    );
  }

  Future<User> login(String username, String password) async {
    final response = await Supabase.instance.client.functions.invoke(
      'auth-user',
      body: {
        'action': 'login',
        'username': username,
        'password': password,
      },
    );

    final data = response.data;

    debugPrint('LOGIN STATUS: ${response.status}');

    if (response.status != 200 ||
        data is! Map ||
        data['user'] is! Map ||
        data['sessionToken'] is! String) {
      final message =
          data is Map && data['error'] is String
              ? data['error'] as String
              : 'Login gagal: respons user atau sessionToken tidak valid';

      throw Exception(message);
    }

    final sessionToken = data['sessionToken'] as String;
    await sessionStorage.saveSessionToken(sessionToken);

    final row = Map<String, dynamic>.from(data['user'] as Map);
    final functionUser = _mapFunctionUser(row);

    // Ambil data terbaru dari database, termasuk foto profil.
    final savedUser = await repository.getUserById(functionUser.id);

    final user = savedUser ?? functionUser;

    await sessionStorage.saveUserId(user.id);
    await sessionStorage.saveLastActivity();

    // Perbarui akun yang digunakan oleh fingerprint.
    await biometricCredentials.saveCredentials(
      username: username,
      password: password,
    );

    await sessionStorage.saveBiometricUserId(user.id);

    _currentUser = user;
    startSessionTimer();
    notifyListeners();

    return user;
  }


  //Fungsi ini akan memulihkan pengguna jika ID masih ditemukan dan waktu tidak aktif belum mencapai satu menit. 
  //Jika tidak valid, session dihapus.
  static const Duration sessionTimeout = Duration(minutes: 10);

  Future<void> restoreSession() async {
    final userId = await sessionStorage.getUserId();
    final lastActivity = await sessionStorage.getLastActivity();

    if (userId == null || lastActivity == null) {
      await logout();
      return;
    }

    final inactiveDuration = DateTime.now().difference(lastActivity);

    if (inactiveDuration >= sessionTimeout) {
      await logout();
      return;
    }

    // Repository mengambil foto dari kolom profile_image_url.
    final user = await repository.getUserById(userId);

    if (user == null) {
      await logout();
      return;
    }

    _currentUser = user;
    startSessionTimer();
    notifyListeners();
  }

  Future<void> updateLastActivity() async {
    if (!isLoggedIn) return;

    await sessionStorage.saveLastActivity();
  }

  Timer? _sessionTimer;

  void startSessionTimer() {
    _sessionTimer?.cancel();

    _sessionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        if (!isLoggedIn) {
          _sessionTimer?.cancel();
          return;
        }

        final lastActivity = await sessionStorage.getLastActivity();

        if (lastActivity == null ||
            DateTime.now().difference(lastActivity) >= sessionTimeout) {
          await logout();
        }
      },
    );
  }

  Future<void> logout() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    await sessionStorage.clearSession();

    _currentUser = null;
    notifyListeners();
  }

  Future<void> deleteAccount(int id) async {
    await repository.deleteUser(id);

    if (_currentUser?.id == id) {
      await logout();
    }
  }

  Future<void> savePreferences({
    required List<int> districtIds,
    required List<int> categoryIds,
  }) async {
    final user = _currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    await repository.savePreferences(
      userId: user.id,
      districtIds: districtIds,
      categoryIds: categoryIds,
    );

    // Pertahankan foto profil dan data user lainnya.
    final refreshedUser = await repository.getUserById(user.id);

    _currentUser = refreshedUser ??
        User(
          id: user.id,
          fullname: user.fullname,
          username: user.username,
          password: user.password,
          districts: user.districts,
          categories: user.categories,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          hasCompletedPreference: true,
          profileImageBase64: user.profileImageBase64,
        );

    notifyListeners();
  }

  User _mapFunctionUser(Map<String, dynamic> row) {
    return User(
      id: (row['id'] as num).toInt(),
      fullname: row['fullname'] as String? ?? '',
      username: row['username'] as String? ?? '',
      password: '',
      districts: const [],
      categories: const [],
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      hasCompletedPreference:
          row['has_completed_preference'] as bool? ?? false,
      profileImageBase64: row['profile_image_url'] as String?,
    );
  }
}
