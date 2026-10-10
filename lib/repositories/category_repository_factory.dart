import 'package:waylo/repositories/category_repository.dart';
import 'package:waylo/repositories/category_repository_impl.dart';

class CategoryRepositoryFactory {
  static CategoryRepository create() {
    return CategoryRepositoryImpl();
  }
}