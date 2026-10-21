
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/service/session_storage.dart';

class UserPreferenceService {
  final SupabaseClient _supabase;
  final SessionStorage _sessionStorage;

  UserPreferenceService(
    this._supabase,
    this._sessionStorage,
  );

  Future<({List<int> categoryIds, List<int> districtIds})>
      getUserPreferences() async {
    final token = await _sessionStorage.getSessionToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await _supabase.functions.invoke(
      'get-user-preferences',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = response.data;

    if (response.status != 200 ||
        data is! Map ||
        data['success'] != true) {
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : 'Gagal mengambil preferensi pengguna';

      throw Exception(message);
    }

    final categoryIds = (data['categoryIds'] as List)
        .map((id) => (id as num).toInt())
        .toList();

    final districtIds = (data['districtIds'] as List)
        .map((id) => (id as num).toInt())
        .toList();

    return (
      categoryIds: categoryIds,
      districtIds: districtIds,
    );
  }
}
