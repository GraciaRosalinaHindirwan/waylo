import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/repositories/category/category_repository.dart';
import 'package:waylo/repositories/category/category_supabase_repository.dart';

class CategoryRepositoryFactory {
  static CategoryRepository create() {
    return CategorySupabaseRepository(
      Supabase.instance.client, 
    );
  }
}