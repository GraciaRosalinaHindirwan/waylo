import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';
import 'package:waylo/service/session_storage.dart';

class FavoriteSupabaseRepository implements FavoriteRepository {
  final SupabaseClient _supabase;
  final SessionStorage _sessionStorage;

  FavoriteSupabaseRepository({
    required SupabaseClient supabase,
    required SessionStorage sessionStorage,
  })  : _supabase = supabase,
        _sessionStorage = sessionStorage;

  Future<Map<String, dynamic>> _invoke({
    required String action,
    int? destinationId,
  }) async {
    final token = await _sessionStorage.getSessionToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    final body = <String, dynamic>{
      'action': action,
      if (destinationId != null) 'destinationId': destinationId,
    };

    final response = await _supabase.functions.invoke(
      'manage-favorite',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    final data = response.data;

    if (response.status < 200 ||
        response.status >= 300 ||
        data is! Map ||
        data['success'] != true) {
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : 'Gagal memproses favorite';

      throw Exception(message);
    }

    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<int>> getFavoriteIds() async {
    final data = await _invoke(action: 'list');
    final ids = data['favoriteIds'];

    if (ids is! List) {
      throw Exception('Format daftar favorite tidak valid');
    }

    return ids.map((id) {
      if (id is int) return id;
      if (id is num) return id.toInt();
      return int.parse(id.toString());
    }).toList();
  }

  @override
  Future<bool> isFavorite(int destinationId) async {
    final data = await _invoke(
      action: 'check',
      destinationId: destinationId,
    );

    return data['isFavorite'] == true;
  }

  @override
  Future<void> addFavorite(int destinationId) async {
    await _invoke(
      action: 'add',
      destinationId: destinationId,
    );
  }

  @override
  Future<void> removeFavorite(int destinationId) async {
    await _invoke(
      action: 'remove',
      destinationId: destinationId,
    );
  }
}