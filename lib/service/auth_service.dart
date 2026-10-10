import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user_repository.dart';
import 'package:waylo/service/password_hasher.dart';

class AuthService {
  final UserRepository repository;

  AuthService(this.repository);

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

  Future<User> login(String username) async {
    final user = await repository.getUserByUsername(username);

    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    // Verifikasi password sebaiknya dilakukan oleh backend.
    return user;
  }

  Future<void> deleteAccount(int id) async {
    await repository.deleteUser(id);
  }
}