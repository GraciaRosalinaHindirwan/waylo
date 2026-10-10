import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final List<User> _users = [
    User(
      id: 1,
      fullname: 'Andi Pratama',
      username: 'andi',
      password: 'andi123',
      destinations: ['Japan', 'China'],
      categories: ['Beach', 'Cultural'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    User(
      id: 2,
      fullname: 'Budi Santoso',
      username: 'budi',
      password: 'budi123',
      destinations: ['Indonesia'],
      categories: ['Mountain', 'Nature'],
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ),
    User(
      id: 3,
      fullname: 'Citra Lestari',
      username: 'citra',
      password: 'citra123',
      destinations: ['South Korea', 'Japan'],
      categories: ['Historical', 'Cultural'],
      createdAt: DateTime(2026, 1, 3),
      updatedAt: DateTime(2026, 1, 3),
    ),
    User(
      id: 4,
      fullname: 'Dewi Anggraini',
      username: 'dewi',
      password: 'dewi123',
      destinations: ['Thailand'],
      categories: ['Beach', 'Adventure'],
      createdAt: DateTime(2026, 1, 4),
      updatedAt: DateTime(2026, 1, 4),
    ),
    User(
      id: 5,
      fullname: 'Eko Saputra',
      username: 'eko',
      password: 'eko123',
      destinations: ['China'],
      categories: ['Nature', 'Historical'],
      createdAt: DateTime(2026, 1, 5),
      updatedAt: DateTime(2026, 1, 5),
    ),
  ];

  @override
  Future<User> createUser(User user) async {
    _users.add(user);
    return user;
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    for (final user in _users) {
      if (user.username == username) {
        return user;
      }
    }

    return null;
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    // Model User belum memiliki field email.
    return null;
  }

  @override
  Future<User> updateUser(User user) async {
    final index = _users.indexWhere(
      (existingUser) => existingUser.id == user.id,
    );

    if (index == -1) {
      throw Exception('User tidak ditemukan');
    }

    final updatedUser = User(
      id: user.id,
      fullname: user.fullname,
      username: user.username,
      password: user.password,
      destinations: List<String>.from(user.destinations),
      categories: List<String>.from(user.categories),
      createdAt: _users[index].createdAt,
      updatedAt: DateTime.now(),
    );

    _users[index] = updatedUser;

    return updatedUser;
  }

  @override
  Future<void> deleteUser(int id) async {
    _users.removeWhere((user) => user.id == id);
  }
}