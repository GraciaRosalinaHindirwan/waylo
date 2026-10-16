import 'package:waylo/models/destination.dart';

class DestinationSearchService {
  List<Destination> search({
    required List<Destination> destinations,
    required String query,
  }) {
    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      return destinations;
    }

    return destinations.where((destination) {
      final name = destination.name.toLowerCase();
      final district =
          destination.location.districtName.toLowerCase();
      final province =
          destination.location.provinceName.toLowerCase();

      return name.contains(keyword) ||
          district.contains(keyword) ||
          province.contains(keyword);
    }).toList();
  }
}
