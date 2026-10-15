
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/appColors.dart';

class DestinationMapCard extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;
  final String? distanceLabel;
  final VoidCallback? onTap;

  const DestinationMapCard({
    super.key,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.distanceLabel,
    this.onTap,
  });

  @override
  State<DestinationMapCard> createState() =>
      _DestinationMapCardState();
}

class _DestinationMapCardState
    extends State<DestinationMapCard> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  double? _distanceKm;
  bool _loadingLocation = true;

  LatLng get _destination => LatLng(
        widget.destinationLatitude,
        widget.destinationLongitude,
      );

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _loadingLocation = false);
        }
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

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

      final user = LatLng(
        position.latitude,
        position.longitude,
      );

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

      _fitMapToMarkers();
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  void _fitMapToMarkers() {
    final controller = _mapController;
    if (controller == null) return;

    if (_userLocation == null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_destination, 14),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude < _destination.latitude
            ? _userLocation!.latitude
            : _destination.latitude,
        _userLocation!.longitude < _destination.longitude
            ? _userLocation!.longitude
            : _destination.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude > _destination.latitude
            ? _userLocation!.latitude
            : _destination.latitude,
        _userLocation!.longitude > _destination.longitude
            ? _userLocation!.longitude
            : _destination.longitude,
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 55),
    );
  }

  String get _distanceText {
    if (_distanceKm != null) {
      return '${_distanceKm!.toStringAsFixed(1)} km from your location';
    }

    if (widget.distanceLabel != null) {
      return widget.distanceLabel!;
    }

    return 'Location unavailable';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 245,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _destination,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_userLocation != null) {
                    _fitMapToMarkers();
                  }
                },
                markers: {
                  Marker(
                    markerId:
                        const MarkerId('destination'),
                    position: _destination,
                    infoWindow: const InfoWindow(
                      title: 'Destination',
                    ),
                  ),
                  if (_userLocation != null)
                    Marker(
                      markerId: const MarkerId('user'),
                      position: _userLocation!,
                      infoWindow: const InfoWindow(
                        title: 'Your location',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.secondary,
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loadingLocation
                          ? 'Finding your location...'
                          : _distanceText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (_loadingLocation)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
