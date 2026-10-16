import 'package:waylo/models/destination.dart';

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
}
