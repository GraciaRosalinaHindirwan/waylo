import 'package:flutter/foundation.dart';
import 'package:waylo/local/favorite/favorite_cache_local.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';

class FavoriteOfflineRepository implements FavoriteRepository {
  final FavoriteRepository _remoteRepository;
  final FavoriteCacheService _cacheService;
  final int userId;

  FavoriteOfflineRepository({
    required FavoriteRepository remoteRepository,
    required FavoriteCacheService cacheService,
    required this.userId,
  })  : _remoteRepository = remoteRepository,
        _cacheService = cacheService;

  @override
  
  @override
  Future<List<int>> getFavoriteIds() async {
    try {
      debugPrint('[Favorite Offline] Mengambil data dari Supabase...');

      final favoriteIds = await _remoteRepository.getFavoriteIds();

      debugPrint('[Favorite Offline] Data Supabase: $favoriteIds');

      await _cacheService.saveFavorites(
        userId: userId,
        favoriteIds: favoriteIds,
      );

      debugPrint('[Favorite Offline] Cache Hive berhasil disimpan.');

      return favoriteIds;
    } catch (error) {
      debugPrint('[Favorite Offline] Supabase gagal: $error');
      debugPrint('[Favorite Offline] Mencoba membaca cache Hive...');

      final cachedIds = await _cacheService.getCachedFavorites(userId);

      if (cachedIds != null) {
        debugPrint('[Favorite Offline] Data dari Hive: $cachedIds');
        return cachedIds;
      }

      debugPrint('[Favorite Offline] Cache Hive belum tersedia.');
      rethrow;
    }
  }


  @override
  Future<bool> isFavorite(int destinationId) async {
    final ids = await getFavoriteIds();
    return ids.contains(destinationId);
  }

  @override
  Future<void> addFavorite(int destinationId) {
    return _remoteRepository.addFavorite(destinationId);
  }

  @override
  Future<void> removeFavorite(int destinationId) {
    return _remoteRepository.removeFavorite(destinationId);
  }
}
