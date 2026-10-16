import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<String> getCurrentCity() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception('Layanan lokasi belum aktif');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi tidak diberikan');
    }

    final position = await Geolocator.getCurrentPosition();

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'format': 'jsonv2',
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'zoom': '10',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'WAYLOTravelApp/1.0',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mencari nama lokasi');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;

    final city = address?['city'] ??
        address?['town'] ??
        address?['municipality'] ??
        address?['village'] ??
        address?['county'] ??
        address?['state'];

    if (city == null) {
      throw Exception('Nama kota tidak ditemukan');
    }

    return city.toString();
  }
}
