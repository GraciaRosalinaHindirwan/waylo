import 'package:waylo/repositories/favorite_repository.dart';
import 'package:waylo/repositories/favorite_repository_impl.dart';

class FavoriteRepositoryFactory {
  static final FavoriteRepository _repository =
      FavoriteRepositoryImpl();

  static FavoriteRepository create() {
    return _repository;
  }
}
