import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';
import 'package:waylo/repositories/favorite/favorite_supabase_repository.dart';
import 'package:waylo/service/session_storage.dart';

class FavoriteRepositoryFactory {
  static final FavoriteRepository _repository =
      FavoriteSupabaseRepository(
    supabase: Supabase.instance.client,
    sessionStorage: SessionStorage(),
  );

  static FavoriteRepository create() => _repository;
}