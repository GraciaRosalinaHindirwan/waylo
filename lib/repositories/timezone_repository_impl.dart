import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/timezone.dart';
import 'timezone_repository.dart';

class TimezoneRepositoryImpl implements TimezoneRepository {
  final String baseUrl;

  TimezoneRepositoryImpl({
    required this.baseUrl,
  });

  @override
  Future<List<Timezone>> getAllTimezones() async {
    final response = await http.get(
      Uri.parse('$baseUrl/timezones'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data zona waktu');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return Timezone(
        id: item['id'] as int,
        cityName: item['city_name'] as String,
        timeZoneId: item['time_zone_id'] as String,
        createdAt: DateTime.parse(item['created_at'] as String),
        updatedAt: DateTime.parse(item['updated_at'] as String),
      );
    }).toList();
  }
}
