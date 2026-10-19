import 'dart:math';

import 'package:waylo/factories/destination_repository_factory.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/repositories/destination_repository.dart';

/// Service untuk mengambil data destinasi dari sumber data utama Waylo.
/// Menggunakan repository yang sama dengan halaman Home/Explore.
class DestinationService {
  DestinationService({DestinationRepository? repository})
      : _repository = repository ?? DestinationRepositoryFactory.create();

  final DestinationRepository _repository;
  final Random _random = Random();

  List<Destination>? _cachedDestinations;

  /// Mengambil seluruh destinasi. Hasil disimpan agar game tidak
  /// mengakses database/API berulang kali setiap koin ditemukan.
  Future<List<Destination>> getAllDestinations({bool refresh = false}) async {
    if (!refresh && _cachedDestinations != null) {
      return List.unmodifiable(_cachedDestinations!);
    }

    final destinations = await _repository.getAllDestinations();
    _cachedDestinations = List<Destination>.from(destinations);
    return List.unmodifiable(_cachedDestinations!);
  }

  /// Mengambil satu destinasi secara acak dari data repository.
  Future<Destination?> getRandomDestination() async {
    final destinations = await getAllDestinations();
    if (destinations.isEmpty) return null;
    return destinations[_random.nextInt(destinations.length)];
  }

  /// Memilih URL gambar banner, atau gambar pertama jika banner tidak ada.
  String? getImageUrl(Destination destination) {
    if (destination.images.isEmpty) return null;

    for (final image in destination.images) {
      if (image.isBanner && image.imageUrl.trim().isNotEmpty) {
        return image.imageUrl.trim();
      }
    }

    for (final image in destination.images) {
      if (image.imageUrl.trim().isNotEmpty) {
        return image.imageUrl.trim();
      }
    }

    return null;
  }
}
