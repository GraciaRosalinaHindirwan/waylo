import 'package:hive_flutter/hive_flutter.dart';

class FavoriteLocalSource {
  static const String _boxName = 'favorite_cache';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }

  // Simpan daftar ID destinasi favorit berdasarkan user.
  Future<void> saveFavoriteIds({
    required int userId,
    required List<int> favoriteIds,
  }) async {
    final box = await _openBox();

    await box.put(userId.toString(), favoriteIds);
  }

  // Ambil daftar ID favorit dari cache.
  Future<List<int>?> getFavoriteIds(int userId) async {
    final box = await _openBox();
    final data = box.get(userId.toString());

    if (data == null) return null;

    return (data as List)
        .map((id) => (id as num).toInt())
        .toList();
  }

  // Hapus cache favorit milik user tertentu.
  Future<void> clearFavoriteIds(int userId) async {
    final box = await _openBox();

    await box.delete(userId.toString());
  }
}
