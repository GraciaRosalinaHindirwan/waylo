import 'package:flutter/foundation.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user_repository.dart';
import 'package:waylo/service/password_hasher.dart';
import 'package:waylo/service/session_storage.dart';

class AuthService extends ChangeNotifier {
  final UserRepository repository;
  final SessionStorage sessionStorage; 

  AuthService(
    this.repository, 
    this.sessionStorage,
  );

  // User yang sedang login pada aplikasi.
  User? _currentUser;

  // Akses untuk membaca session dari halaman lain.
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

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
    notifyListeners();

    return user;
  }
  // Mengakhiri session.
  Future<void> logout() async {
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
