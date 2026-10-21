
import 'package:waylo/models/destination.dart';

class RecommendationService {
  List<Destination> rankDestinations({
    required List<Destination> destinations,
    required List<int> preferredCategoryIds,
    required List<int> preferredDistrictIds,
  }) {
    final categoryIds = preferredCategoryIds.toSet();
    final districtIds = preferredDistrictIds.toSet();

    // Belum ada preference, jangan tampilkan semua destinasi.
    if (categoryIds.isEmpty || districtIds.isEmpty) {
      return [];
    }

    // Hanya ambil destinasi yang cocok dengan category ATAU district.
    final matchingDestinations = destinations.where((destination) {
      final categoryMatch = destination.categories.any(
        (category) => categoryIds.contains(category.id),
      );

      final districtMatch = districtIds.contains(
        destination.location.idDistrict,
      );

      return categoryMatch;
    }).toList();

    // Urutkan: cocok kategori + district lebih diutamakan.
    matchingDestinations.sort((a, b) {
      int score(Destination destination) {
        final categoryMatch = destination.categories.any(
          (category) => categoryIds.contains(category.id),
        );

        final districtMatch = districtIds.contains(
          destination.location.idDistrict,
        );

        return (categoryMatch ? 2 : 0) +
            (districtMatch ? 1 : 0);
      }

      return score(b).compareTo(score(a));
    });

    return matchingDestinations;
  }
}
