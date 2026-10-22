import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waylo/components/smart_compass.dart';

import '../theme/appColors.dart';

class MapCard extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String destinationName;

  const MapCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.destinationName,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  double? _distanceKm;
  bool _loadingLocation = true;

  LatLng get _destination => LatLng(widget.latitude, widget.longitude);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _loadingLocation = false);
        }
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _loadingLocation = false);
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final user = LatLng(position.latitude, position.longitude);

      final distance = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        _destination.latitude,
        _destination.longitude,
      );

      if (!mounted) return;

      setState(() {
        _userLocation = user;
        _distanceKm = distance / 1000;
        _loadingLocation = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = _destination;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 245,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: destination,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.waylo',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: destination,
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.accent,
                            size: 42,
                          ),
                        ),
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(top: 12, right: 12, child: SmartCompass()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                const Icon(
                  Icons.person_pin_circle_rounded,
                  color: AppColors.secondary,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loadingLocation
                        ? 'Finding your location...'
                        : _distanceKm != null
                        ? '${_distanceKm!.toStringAsFixed(1)} km from your location'
                        : 'Location unavailable',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// cara pake
// MapCard(
//   latitude: -7.7956,
//   longitude: 110.3695,
//   destinationName: 'Yogyakarta',
// )
