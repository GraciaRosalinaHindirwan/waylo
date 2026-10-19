import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' hide Category;

import 'package:waylo/repositories/category/category_repository.dart';
import 'package:waylo/repositories/category/category_repository_factory.dart';
import 'package:waylo/models/category.dart';

class CategorySupabaseRepository implements CategoryRepository{
  final SupabaseClient _supabase;

  CategorySupabaseRepository(this._supabase);

  @override
  Future<List<Category>> getAllCategories() async{
    final response = await _supabase
      .from('category')
      .select()
      .order('id', ascending: true); 

    return (response as List)
      .map(
        (row) => Category(
          id: row['id'] as int,
          name: row['name'] as String,
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ),
      )
      .toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async{
    final response = await _supabase
      .from('category')
      .select()
      .eq('id', id)
      .maybeSingle(); 

      if (response == null) return null;

    return _mapCategory(response);
  }

  @override
  Future<Category?> getCategoryByName(String name) async {
    final response = await _supabase
        .from('category')
        .select()
        .ilike('name', name)
        .maybeSingle();

    if (response == null) return null;

    return _mapCategory(response);
  }

  Category _mapCategory(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as int,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}