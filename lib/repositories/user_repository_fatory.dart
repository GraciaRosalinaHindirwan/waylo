import 'package:waylo/repositories/user_repository.dart';
import 'package:waylo/repositories/user_repository_impl.dart';

class UserRepositoryFactory {
  static UserRepository create() {
    return UserRepositoryImpl();
  }
}
