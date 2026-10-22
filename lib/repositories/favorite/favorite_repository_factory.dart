import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/local/favorite/favorite_cache_local.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';
import 'package:waylo/repositories/favorite/favorite_supabase_repository.dart';
import 'package:waylo/repositories/favorite/favorite_offline_repository.dart';
import 'package:waylo/service/session_storage.dart';

class FavoriteRepositoryFactory {
  static FavoriteRepository create({
    required int userId,
  }) {
    final remoteRepository = FavoriteSupabaseRepository(
      supabase: Supabase.instance.client,
      sessionStorage: SessionStorage(),
    );

    return FavoriteOfflineRepository(
      remoteRepository: remoteRepository,
      cacheService: FavoriteCacheService(),
      userId: userId,
    );
  }
}
