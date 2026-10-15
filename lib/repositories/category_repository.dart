import 'package:waylo/models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();

  Future<Category?> getCategoryById(int id);

  Future<Category?> getCategoryByName(String name);
}