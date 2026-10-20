import 'package:waylo/models/user.dart';

//petugas yang mengambil data namanya interface 
abstract class UserRepository {
  // CREATE
  Future<User> createUser(User user);
  
  Future<User?> getUserById(int id);

  // READ
  Future<User?> getUserByUsername(String username);

  // UPDATE
  Future<User> updateUser(User user);

  // DELETE
  Future<void> deleteUser(int id);

  Future<void> initializeDummyUsers();

  //preferance
  Future<void> savePreferences({
    required int userId,
    required List<int> districtIds,
    required List<int> categoryIds,
  });
}
