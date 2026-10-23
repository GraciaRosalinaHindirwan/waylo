import 'package:latlong2/latlong.dart';

class SelectedLocation {
  final LatLng coordinates;
  final String name;

  const SelectedLocation({
    required this.coordinates,
    required this.name,
  });
}