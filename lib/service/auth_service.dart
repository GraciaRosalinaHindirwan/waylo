import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user/user_repository.dart';
import 'package:waylo/service/password_hasher.dart';
import 'package:waylo/service/session_storage.dart';

class AuthService extends ChangeNotifier {
  final UserRepository repository;
  final SessionStorage sessionStorage; 

  // User yang sedang login pada aplikasi.
  User? _currentUser;

  // Akses untuk membaca session dari halaman lain.
  User? get currentUser => _currentUser;

  // Foto profil diturunkan dari data user yang sedang login (tersimpan di repository).
  Uint8List? get profileImageBytes {
    final base64Image = _currentUser?.profileImageBase64;
    if (base64Image == null) return null;
    return base64Decode(base64Image);
  }

  bool get isLoggedIn => _currentUser != null;

  AuthService(
    this.repository, 
    this.sessionStorage,
  );

  // Dipanggil setelah autentikasi berhasil.
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners(); //changeNotifer supaya kasih tau state udah berubah 
  }

  // Dipanggil saat user ganti foto profil di EditProfilePage
  Future<void> setProfileImage(Uint8List bytes) async {
    final user = _currentUser;
    if (user == null) return;

    final base64Image = base64Encode(bytes);

    final updatedUser = await repository.updateUser(
      User(
        id: user.id,
        fullname: user.fullname,
        username: user.username,
        password: user.password,
        destinations: user.destinations,
        categories: user.categories,
        hasCompletedPreference: user.hasCompletedPreference,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
        profileImageBase64: base64Image,
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

    if (response.status != 201 || data is! Map || data['user'] is! Map) {
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : 'Registrasi gagal';

      throw Exception(message);
    }

    final row = Map<String, dynamic>.from(data['user'] as Map);

    return _mapFunctionUser(row);
  }


  Future<void> enableBiometricLogin(int userId) async {
  await sessionStorage.saveBiometricUserId(userId);
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

    if (response.status != 200 || data is! Map || data['user'] is! Map) {
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : 'Username atau password salah';

      throw Exception(message);
    }

    final row = Map<String, dynamic>.from(data['user'] as Map);
    final user = _mapFunctionUser(row);

    await sessionStorage.saveUserId(user.id);
    await sessionStorage.saveLastActivity();

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

  // Mengakhiri session.
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

  User _mapFunctionUser(Map<String, dynamic> row) {
    return User(
      id: (row['id'] as num).toInt(),
      fullname: row['fullname'] as String,
      username: row['username'] as String,
      password: '',
      destinations: const [],
      categories: const [],
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      hasCompletedPreference: false,
      profileImageBase64: null,
    );
  }

}