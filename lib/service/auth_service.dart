import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user_repository.dart';
import 'package:waylo/service/password_hasher.dart';
import 'package:waylo/service/session_storage.dart';

class AuthService extends ChangeNotifier {
  final UserRepository repository;
  final SessionStorage sessionStorage; 

  // User yang sedang login pada aplikasi.
  User? _currentUser;

  // Akses untuk membaca session dari halaman lain.
  User? get currentUser => _currentUser;

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

  Future<User> register(User user) async {
    final existingUser =
        await repository.getUserByUsername(user.username);

    if (existingUser != null) {
      throw Exception('Username sudah digunakan');
    }

    final hashedPassword =
        await PasswordHasher.hashPassword(user.password);

    final newUser = User(
      id: user.id,
      fullname: user.fullname,
      username: user.username,
      password: hashedPassword,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.createUser(newUser);
  }

  Future<User> login(
    String username,
    String password,
  ) async {
    final user = await repository.getUserByUsername(username);

    if (user == null) {
      throw Exception('Username atau password salah');
    }

    final isValid = await PasswordHasher.verifyPassword(
      password: password,
      hashedPassword: user.password, 
    );

    if (!isValid) {
      throw Exception('Username atau password salah');
    }

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
}
