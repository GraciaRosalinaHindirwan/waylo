import 'package:waylo/local/favorite/favorite_local_source.dart';

class FavoriteCacheService {
  final FavoriteLocalSource _localSource;

  FavoriteCacheService({
    FavoriteLocalSource? localSource,
  }) : _localSource = localSource ?? FavoriteLocalSource();

  /// Simpan daftar ID favorit milik user ke Hive.
  Future<void> saveFavorites({
    required int userId,
    required List<int> favoriteIds,
  }) async {
    await _localSource.saveFavoriteIds(
      userId: userId,
      favoriteIds: favoriteIds,
    );
  }

  /// Ambil daftar ID favorit dari Hive.
  Future<List<int>?> getCachedFavorites(int userId) async {
    return _localSource.getFavoriteIds(userId);
  }

  /// Hapus cache favorit milik user tertentu.
  Future<void> clearCache(int userId) async {
    await _localSource.clearFavoriteIds(userId);
  }
}
