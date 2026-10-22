
import 'package:hive_flutter/hive_flutter.dart';

class DestinationLocalSource {
  static const String _boxName = 'destination_cache';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }

  // Simpan daftar destinasi berdasarkan user atau cache global.
  Future<void> saveDestinations(
    List<Map<String, dynamic>> destinations, {
    String cacheKey = 'all',
  }) async {
    final box = await _openBox();

    await box.put(cacheKey, destinations);
  }

  // Ambil destinasi yang tersimpan di Hive.
  Future<List<Map<String, dynamic>>?> getDestinations({
    String cacheKey = 'all',
  }) async {
    final box = await _openBox();
    final data = box.get(cacheKey);

    if (data == null) return null;

    return (data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // Hapus cache destinasi tertentu.
  Future<void> clearDestinations({
    String cacheKey = 'all',
  }) async {
    final box = await _openBox();

    await box.delete(cacheKey);
  }
}
