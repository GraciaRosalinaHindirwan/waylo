import 'package:waylo/models/category.dart';
import 'package:waylo/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final List<Category> _categories = [
    Category(
      id: 1,
      name: 'Beach',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 2,
      name: 'Mountain',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 3,
      name: 'Nature',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 4,
      name: 'Cultural',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 5,
      name: 'Historical',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 6,
      name: 'Adventure',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<List<Category>> getAllCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }

    return null;
  }

  @override
  Future<Category?> getCategoryByName(String name) async {
    for (final category in _categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
    }

    return null;
  }
}