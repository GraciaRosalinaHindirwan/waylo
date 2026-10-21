import 'dart:math' as math;
import 'package:waylo/models/destination.dart';
import 'package:flutter/foundation.dart'; 

class RecommendationService {
  List<Destination> rankDestinations({
    required List<Destination> destinations,
    required List<int> preferredCategoryIds,
    required List<int> preferredDistrictIds,
    required List<int> favoriteDestinationIds,
    double? userLatitude,
    double? userLongitude,
  }) {
    final preferredCategories = preferredCategoryIds.toSet();
    final preferredDistricts = preferredDistrictIds.toSet();
    final favoriteIds = favoriteDestinationIds.toSet();

    // Ambil kategori dari destinasi yang di-like pengguna.
    final likedCategoryIds = <int>{};

    for (final destination in destinations) {
      if (favoriteIds.contains(destination.id)) {
        likedCategoryIds.addAll(
          destination.categories.map((category) => category.id),
        );
      }
    }

    // Gabungkan kategori preference dan kategori dari favorites.
    final interestCategoryIds = {
      ...preferredCategories,
      ...likedCategoryIds,
    };

    // Tidak ada informasi minat yang bisa digunakan.
    if (interestCategoryIds.isEmpty) {
      return [];
    }

    // Hanya tampilkan destinasi yang kategorinya relevan.
    final filtered = destinations.where((destination) {
      return destination.categories.any(
        (category) => interestCategoryIds.contains(category.id),
      );
    }).toList();

    // Menghitung jarak pengguna ke destinasi dalam kilometer.
    double distanceKm(Destination destination) {
      if (userLatitude == null || userLongitude == null) {
        return double.infinity;
      }

      const earthRadiusKm = 6371.0;

      final lat1 = userLatitude * math.pi / 180;
      final lat2 = destination.coordinate.latitude * math.pi / 180;

      final deltaLat =
          (destination.coordinate.latitude - userLatitude) *
              math.pi /
              180;

      final deltaLon =
          (destination.coordinate.longitude - userLongitude) *
              math.pi /
              180;

      final a = (
        math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.pow(math.sin(deltaLon / 2), 2)
      ).clamp(0.0, 1.0);

      return earthRadiusKm * 2 * math.asin(math.sqrt(a));
    }

    // Skor untuk mengurutkan kecocokan rekomendasi.
    int preferenceScore(Destination destination) {
      final matchesPreferredCategory = destination.categories.any(
        (category) => preferredCategories.contains(category.id),
      );

      final matchesLikedCategory = destination.categories.any(
        (category) => likedCategoryIds.contains(category.id),
      );

      final matchesPreferredDistrict = preferredDistricts.contains(
        destination.location.idDistrict,
      );

      return (matchesPreferredCategory ? 4 : 0) +
          (matchesLikedCategory ? 2 : 0) +
          (matchesPreferredDistrict ? 1 : 0);
    }

    filtered.sort((a, b) {
      final scoreA = preferenceScore(a);
      final scoreB = preferenceScore(b);

      final scoreComparison = scoreB.compareTo(scoreA);

      // Prioritaskan skor kecocokan yang lebih tinggi.
      if (scoreComparison != 0) return scoreComparison;

      // Jika skor sama, prioritaskan jarak yang lebih dekat.
      return distanceKm(a).compareTo(distanceKm(b));
    });

    // DEBUG: tampilkan skor dan jarak setiap rekomendasi.
    for (final destination in filtered) {
      debugPrint(
        'DESTINATION: ${destination.name} | '
        'SCORE: ${preferenceScore(destination)} | '
        'DISTANCE: ${distanceKm(destination).toStringAsFixed(2)} km',
      );
    }

return filtered;

    return filtered;
  }
}
