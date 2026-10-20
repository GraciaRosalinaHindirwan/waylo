import 'package:flutter/foundation.dart';
import 'package:waylo/local/destination/destination_cache_service.dart';
import 'package:waylo/local/favorite/favorite_cache_local.dart';


Future<void> testHiveCache() async {
  final favoriteCache = FavoriteCacheService();
  final destinationCache = DestinationCacheService();

  try {
    // TEST FAVORITES
    await favoriteCache.saveFavorites(
      userId: 8,
      favoriteIds: [1, 3, 7],
    );

    final savedFavorites =
        await favoriteCache.getCachedFavorites(8);

    debugPrint('Hive Favorites: $savedFavorites');

    // TEST DESTINATIONS
    final destinations = [
      {
        'id': 1,
        'name': 'Great Wall of China',
        'country': 'China',
        'category': 'Historical',
      },
      {
        'id': 2,
        'name': 'West Lake',
        'country': 'China',
        'category': 'Nature',
      },
    ];

    await destinationCache.saveDestinations(destinations);

    final savedDestinations =
        await destinationCache.getCachedDestinations();

    debugPrint('Hive Destinations: $savedDestinations');
  } catch (e, stackTrace) {
    debugPrint('Hive cache test gagal: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}
