
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waylo/models/travel_badge.dart';
import 'package:waylo/models/user_badge.dart';
import 'package:waylo/repositories/badge/travel_badge_repository.dart';
import 'package:waylo/service/session_storage.dart';

class TravelBadgeSupabaseRepository implements TravelBadgeRepository {
  final SupabaseClient _supabase;
  final SessionStorage _sessionStorage;

  TravelBadgeSupabaseRepository(
    this._supabase,
    this._sessionStorage,
  );

  @override
  Future<List<TravelBadge>> getAllBadges() async {
    final response = await _supabase
        .from('travel_badges')
        .select()
        .order('name');

    return (response as List).map((row) {
      final data = Map<String, dynamic>.from(row);

      final typeName = data['type'] as String;
      final type = BadgeType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => throw FormatException(
          'BadgeType tidak dikenal: $typeName',
        ),
      );

      return TravelBadge(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        icon: data['icon'] as String,
        targetCount: (data['target_count'] as num).toInt(),
        type: type,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _invokeBadgeFunction(
    Map<String, dynamic> body,
  ) async {
    final token = await _sessionStorage.getSessionToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await _supabase.functions.invoke(
      'manage-user-badges',
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    final data = response.data;

    if (response.status != 200 ||
        data is! Map ||
        data['success'] != true) {
      final message =
          data is Map && data['error'] is String
              ? data['error'] as String
              : 'Gagal memproses badge pengguna';

      throw Exception(message);
    }

    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<UserBadge>> getUserBadges(int userId) async {
    final data = await _invokeBadgeFunction({
      'action': 'list',
    });

    final rows = data['badges'];

    if (rows is! List) {
      throw const FormatException(
        'Format data badge pengguna tidak valid.',
      );
    }

    return rows.map((row) {
      final item = Map<String, dynamic>.from(row);

      return UserBadge(
        userId: (item['user_id'] as num).toInt(),
        badgeId: item['badge_id'] as String,
        progress: (item['progress'] as num).toInt(),
        isUnlocked: item['is_unlocked'] as bool,
        unlockedAt: item['unlocked_at'] == null
            ? null
            : DateTime.parse(
                item['unlocked_at'] as String,
              ),
      );
    }).toList();
  }

  /// Mencatat kunjungan destinasi melalui Edge Function.
  /// Progres badge dihitung oleh backend, bukan Flutter.
  Future<void> recordDestinationVisit({
    required String destinationId,
  }) async {
    await _invokeBadgeFunction({
      'action': 'record_visit',
      'destinationId': destinationId,
    });
  }

  @override
  Future<void> saveUserBadge(UserBadge userBadge) async {
    throw UnsupportedError(
      'Progres badge dihitung oleh backend melalui recordDestinationVisit().',
    );
  }
}
