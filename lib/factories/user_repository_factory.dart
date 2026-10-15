import 'package:waylo/repositories/user_repository.dart';
import 'package:waylo/implementations/user_repository_impl.dart';

// petugas yang menyiapkan pekerja, 
// kalau diubah nanti cukup di sini saja, 
// tidak perlu diubah di tempat lain
class UserRepositoryFactory {
  static Future<UserRepository> create() async {
    return await UserRepositoryImpl.create();
  }
}
