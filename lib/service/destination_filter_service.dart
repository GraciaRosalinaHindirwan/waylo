import 'package:waylo/models/destination.dart';
import 'package:geolocator/geolocator.dart';

class DestinationFilterService {
  List<String> getDistricts(List<Destination> destinations) {
    final districts = destinations
        .map((destination) =>
            destination.location.districtName.trim())
        .where((district) => district.isNotEmpty)
        .toSet()
        .toList();

    districts.sort();
    return districts;
  }

  List<Destination> filter({
    required List<Destination> destinations,
    required Set<int> categoryIds,
    required int? minFee,
    required int? maxFee,
    required String? district,
  }) {
    return destinations.where((destination) {
      if (categoryIds.isNotEmpty &&
          !destination.categories.any(
            (category) => categoryIds.contains(category.id),
          )) {
        return false;
      }

      final fee = destination.fee;

      if (minFee != null &&
          (fee == null || fee < minFee)) {
        return false;
      }

      if (maxFee != null &&
          (fee == null || fee > maxFee)) {
        return false;
      }

      if (district != null &&
          destination.location.districtName != district) {
        return false;
      }

      return true;
    }).toList();
  }

  List<Destination> getNearbyDestinations({
    required List<Destination> destinations,
    required double userLatitude,
    required double userLongitude,
    double radiusInMeters = 10000,
  }) {
    final nearbyDestinations = destinations.where((destination) {
      final distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        destination.coordinate.latitude,
        destination.coordinate.longitude,
      );

      return distance <= radiusInMeters;
    }).toList();

    nearbyDestinations.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        a.coordinate.latitude,
        a.coordinate.longitude,
      );

      final distanceB = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        b.coordinate.latitude,
        b.coordinate.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return nearbyDestinations;
  }
}
