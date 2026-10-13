import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waylo/models/timezone.dart';
import 'package:waylo/repositories/timezone_repository.dart';

class TimezoneRepositoryImpl implements TimezoneRepository {
  final http.Client client;

  TimezoneRepositoryImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<List<Timezone>> getTimezones() async {
    final url = Uri.parse(
      'https://worldtime.timezone.io/api/timezone',
    );

    try {
      final response = await client.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil zona waktu: ${response.statusCode}',
        );
      }

      final List<dynamic> data = jsonDecode(response.body);
      final now = DateTime.now();

      final timezones = data.asMap().entries.map((entry) {
        final index = entry.key;
        final timeZoneId = entry.value as String;

        // Ambil nama bagian terakhir dari zona waktu.
        // Contoh: Asia/Jakarta menjadi Jakarta.
        final cityName = timeZoneId
            .split('/')
            .last
            .replaceAll('_', ' ');

        return Timezone(
          id: index + 1,
          cityName: cityName,
          timeZoneId: timeZoneId,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      return timezones;
    } catch (e) {
      throw Exception('Gagal memuat zona waktu: $e');
    }
  }
}