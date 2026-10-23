import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:waylo/layouts/subPageLayout.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/models/selected_location.dart';

class ChooseLocationMap extends StatefulWidget {
  final SelectedLocation? initialLocation;

  const ChooseLocationMap({
    super.key,
    this.initialLocation,
  }); 

  @override
  State<ChooseLocationMap> createState() =>
      _ChooseLocationMapState();
}

class _ChooseLocationMapState extends State<ChooseLocationMap> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  late LatLng _selectedLocation;

  late String _selectedLocationName;

  @override
  void initState() {
    super.initState();

    _selectedLocation =
        widget.initialLocation?.coordinates ??
        const LatLng(39.9042, 116.4074);

    _selectedLocationName =
        widget.initialLocation?.name ?? 'Beijing, China';
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchError = 'Masukkan nama kota terlebih dahulu.';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchResults = [];
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': '$query, China',
          'countrycodes': 'cn',
          'format': 'jsonv2',
          'limit': '5',
          'addressdetails': '1',
          'accept-language': 'en',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Waylo/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data lokasi.');
      }

      final List<dynamic> data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        _searchResults = data.cast<Map<String, dynamic>>();

        if (_searchResults.isEmpty) {
          _searchError = 'Lokasi tidak ditemukan di China.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchError = 'Pencarian gagal. Periksa koneksi internet.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _updateLocationName(LatLng location) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'jsonv2',
          'addressdetails': '1',
          'accept-language': 'en',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Waylo/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mendapatkan nama lokasi.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;

      if (!mounted || address == null) return;

      // Tolak koordinat di luar China.
      if (address['country_code']?.toString().toLowerCase() != 'cn') {
        setState(() {
          _searchError = 'Pilih lokasi yang berada di China.';
        });
        return;
      }

      final parts = <String>[
        if (address['suburb'] != null) address['suburb'].toString(),
        if (address['city'] != null)
          address['city'].toString()
        else if (address['town'] != null)
          address['town'].toString()
        else if (address['village'] != null)
          address['village'].toString(),
        if (address['state'] != null) address['state'].toString(),
        if (address['country'] != null) address['country'].toString(),
      ];

      if (parts.isNotEmpty) {
        setState(() {
          _selectedLocationName = parts.toSet().join(', ');
          _searchError = null;
        });
      }
    } catch (e) {
      debugPrint('Gagal mendapatkan nama lokasi: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Choose Location',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your explore location',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchLocation(),
                  decoration: InputDecoration(
                    hintText: 'Search city in China...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSearching ? null : _searchLocation,
                icon: _isSearching
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
              ),
            ],
          ),

          if (_searchError != null) ...[
            const SizedBox(height: 8),
            Text(
              _searchError!,
              style: const TextStyle(color: Colors.red),
            ),
          ],

          if (_searchResults.isNotEmpty)
            SizedBox(
              height: 130,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];

                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(
                      result['display_name']?.toString() ?? 'Unknown location',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final latitude = double.tryParse(
                        result['lat'].toString(),
                      );
                      final longitude = double.tryParse(
                        result['lon'].toString(),
                      );

                      if (latitude == null || longitude == null) return;

                      final location = LatLng(latitude, longitude);

                      setState(() {
                        _selectedLocation = location;
                        _selectedLocationName =
                            result['display_name']?.toString() ?? 'China';
                        _searchResults = [];
                        _searchError = null;
                        _searchController.clear();
                      });

                      _mapController.move(location, 12);
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Peta OSM
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 12,
                      onPositionChanged: (camera, hasGesture) {
                        if (!hasGesture) return;

                        setState(() {
                          _selectedLocation = camera.center;
                        });

                        _updateLocationName(camera.center);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.waylo',
                      ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Pin selalu berada di tengah layar
                  const IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 32),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Selected location',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedLocationName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Text(
            'Selected coordinates',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '${_selectedLocation.latitude.toStringAsFixed(5)}, '
            '${_selectedLocation.longitude.toStringAsFixed(5)}',
          ),

          const SizedBox(height: 16),

          CustomButton(
            text: 'Apply Location',
            onPressed: () {
              Navigator.pop(
                context,
                SelectedLocation(
                  coordinates: _selectedLocation,
                  name: _selectedLocationName,
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
