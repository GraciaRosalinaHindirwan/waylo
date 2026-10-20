abstract class FavoriteRepository {
  Future<List<int>> getFavoriteIds();

  Future<bool> isFavorite(int destinationId);

  Future<void> addFavorite(int destinationId);

  Future<void> removeFavorite(int destinationId);
}