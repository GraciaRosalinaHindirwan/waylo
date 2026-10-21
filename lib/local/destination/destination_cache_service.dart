import 'package:waylo/local/destination/destination_local_source.dart';
import 'package:waylo/models/destination.dart';
import 'package:flutter/foundation.dart';

class DestinationCacheService {
  final DestinationLocalSource _localSource;

  DestinationCacheService({
    DestinationLocalSource? localSource,
  }) : _localSource = localSource ?? DestinationLocalSource();

  /// Simpan daftar destinasi ke Hive.
  Future<void> saveDestinations(
    List<Map<String, dynamic>> destinations, {
    String cacheKey = 'all',
  }) async {
    await _localSource.saveDestinations(
      destinations,
      cacheKey: cacheKey,
    );
  }

  /// Ambil daftar destinasi dari Hive.
  Future<List<Map<String, dynamic>>?> getCachedDestinations({
    String cacheKey = 'all',
  }) async {
    return _localSource.getDestinations(
      cacheKey: cacheKey,
    );
  }

  /// Hapus cache destinasi.
  Future<void> clearCache({
    String cacheKey = 'all',
  }) async {
    await _localSource.clearDestinations(
      cacheKey: cacheKey,
    );
  }

  // Simpan objek destinasi ke Hive.
  Future<void> saveDestinationModels(
    List<Destination> destinations, {
    String cacheKey = 'all',
  }) async {
    final data = destinations
        .map((destination) => destination.toJson())
        .toList();

    for (final destination in destinations) {
    debugPrint(
      '[Hive] Destination: ${destination.name}',
    );

    debugPrint(
      '[Hive] Jumlah gambar: ${destination.images.length}',
    );

    for (final image in destination.images) {
      debugPrint(
        '[Hive] Image ID: ${image.id}, '
        'isBanner: ${image.isBanner}, '
        'URL: ${image.imageUrl}',
      );
    }
  }

    await _localSource.saveDestinations(
      data,
      cacheKey: cacheKey,
    );
  }

  // Ambil objek destinasi dari Hive.
  Future<List<Destination>?> getCachedDestinationModels({
    String cacheKey = 'all',
  }) async {
    final data = await _localSource.getDestinations(
      cacheKey: cacheKey,
    );

    if (data == null) return null;

    return data
        .map((item) => Destination.fromJson(item))
        .toList();
  }
}
