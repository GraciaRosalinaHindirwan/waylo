import 'package:waylo/models/user.dart';

abstract class UserRepository {
  // CREATE
  Future<User> createUser(User user);

  // READ
  Future<User?> getUserByUsername(String username);

  // UPDATE
  Future<User> updateUser(User user);

  // DELETE
  Future<void> deleteUser(int id);
}
