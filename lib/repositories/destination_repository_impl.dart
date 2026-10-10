import 'package:waylo/models/category.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/models/location.dart';
import 'package:waylo/repositories/destination_repository.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  final List<Category> _categories = [
    Category(
      id: 1,
      name: 'Beach',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 2,
      name: 'Mountain',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 3,
      name: 'Nature',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 4,
      name: 'Cultural',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 5,
      name: 'Historical',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Category(
      id: 6,
      name: 'Adventure',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  final List<Location> _locations = [
    Location(
      idProvince: 34,
      idCountry: 1,
      provinceName: 'DI Yogyakarta',
      idDistrict: 3471,
      districtName: 'Kota Yogyakarta',
      postalCode: 55111,
      subdistrictName: 'Sosromenduran',
      provinceCreatedAt: DateTime(2026, 1, 1),
      provinceUpdatedAt: DateTime(2026, 1, 1),
      districtCreatedAt: DateTime(2026, 1, 1),
      districtUpdatedAt: DateTime(2026, 1, 1),
      subdistrictCreatedAt: DateTime(2026, 1, 1),
      subdistrictUpdatedAt: DateTime(2026, 1, 1),
    ),
    Location(
      idProvince: 34,
      idCountry: 1,
      provinceName: 'DI Yogyakarta',
      idDistrict: 3471,
      districtName: 'Kota Yogyakarta',
      postalCode: 55171,
      subdistrictName: 'Patehan',
      provinceCreatedAt: DateTime(2026, 1, 1),
      provinceUpdatedAt: DateTime(2026, 1, 1),
      districtCreatedAt: DateTime(2026, 1, 1),
      districtUpdatedAt: DateTime(2026, 1, 1),
      subdistrictCreatedAt: DateTime(2026, 1, 1),
      subdistrictUpdatedAt: DateTime(2026, 1, 1),
    ),
    Location(
      idProvince: 34,
      idCountry: 1,
      provinceName: 'DI Yogyakarta',
      idDistrict: 3402,
      districtName: 'Kabupaten Bantul',
      postalCode: 55792,
      subdistrictName: 'Parangtritis',
      provinceCreatedAt: DateTime(2026, 1, 1),
      provinceUpdatedAt: DateTime(2026, 1, 1),
      districtCreatedAt: DateTime(2026, 1, 1),
      districtUpdatedAt: DateTime(2026, 1, 1),
      subdistrictCreatedAt: DateTime(2026, 1, 1),
      subdistrictUpdatedAt: DateTime(2026, 1, 1),
    ),
    Location(
      idProvince: 34,
      idCountry: 1,
      provinceName: 'DI Yogyakarta',
      idDistrict: 3402,
      districtName: 'Kabupaten Bantul',
      postalCode: 55792,
      subdistrictName: 'Mangunan',
      provinceCreatedAt: DateTime(2026, 1, 1),
      provinceUpdatedAt: DateTime(2026, 1, 1),
      districtCreatedAt: DateTime(2026, 1, 1),
      districtUpdatedAt: DateTime(2026, 1, 1),
      subdistrictCreatedAt: DateTime(2026, 1, 1),
      subdistrictUpdatedAt: DateTime(2026, 1, 1),
    ),
    Location(
      idProvince: 34,
      idCountry: 1,
      provinceName: 'DI Yogyakarta',
      idDistrict: 3404,
      districtName: 'Kabupaten Sleman',
      postalCode: 55582,
      subdistrictName: 'Bokoharjo',
      provinceCreatedAt: DateTime(2026, 1, 1),
      provinceUpdatedAt: DateTime(2026, 1, 1),
      districtCreatedAt: DateTime(2026, 1, 1),
      districtUpdatedAt: DateTime(2026, 1, 1),
      subdistrictCreatedAt: DateTime(2026, 1, 1),
      subdistrictUpdatedAt: DateTime(2026, 1, 1),
    ),
  ];

  late final List<Destination> _destinations = [
    Destination(
      id: 1,
      location: _locations[0],
      name: 'Malioboro',
      description: 'Kawasan wisata dan belanja populer di Yogyakarta.',
      fee: 0,
      openingHour: '00:00:00',
      closingHour: '23:59:59',
      longitude: 110.3671,
      latitude: -7.7926,
      rating: 4.8,
      categories: [_categories[3], _categories[4]],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Destination(
      id: 2,
      location: _locations[1],
      name: 'Taman Sari',
      description: 'Kompleks bersejarah bekas taman kerajaan Yogyakarta.',
      fee: 15000,
      openingHour: '09:00:00',
      closingHour: '15:00:00',
      longitude: 110.3592,
      latitude: -7.8101,
      rating: 4.7,
      categories: [_categories[3], _categories[4]],
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ),
    Destination(
      id: 3,
      location: _locations[2],
      name: 'Pantai Parangtritis',
      description: 'Pantai populer dengan pemandangan laut dan pasir luas.',
      fee: 15000,
      openingHour: '00:00:00',
      closingHour: '23:59:59',
      longitude: 110.3292,
      latitude: -8.0246,
      rating: 4.6,
      categories: [_categories[0], _categories[2]],
      createdAt: DateTime(2026, 1, 3),
      updatedAt: DateTime(2026, 1, 3),
    ),
    Destination(
      id: 4,
      location: _locations[3],
      name: 'Hutan Pinus Mangunan',
      description: 'Destinasi alam dengan pemandangan hutan pinus.',
      fee: 5000,
      openingHour: '06:00:00',
      closingHour: '18:00:00',
      longitude: 110.4317,
      latitude: -7.9372,
      rating: 4.5,
      categories: [_categories[1], _categories[2]],
      createdAt: DateTime(2026, 1, 4),
      updatedAt: DateTime(2026, 1, 4),
    ),
    Destination(
      id: 5,
      location: _locations[4],
      name: 'Candi Prambanan',
      description: 'Kompleks candi Hindu bersejarah di Yogyakarta.',
      fee: 50000,
      openingHour: '06:30:00',
      closingHour: '17:00:00',
      longitude: 110.4915,
      latitude: -7.7520,
      rating: 4.8,
      categories: [_categories[3], _categories[4]],
      createdAt: DateTime(2026, 1, 5),
      updatedAt: DateTime(2026, 1, 5),
    ),
  ];

  @override
  Future<Destination?> getDestinationById(int id) async {
    for (final destination in _destinations) {
      if (destination.id == id) {
        return destination;
      }
    }

    return null;
  }

  @override
  Future<List<Destination>> getAllDestinations() async {
    return List.unmodifiable(_destinations);
  }

  @override
  Future<List<Destination>> getDestinationsByCategory(
    int categoryId,
  ) async {
    return _destinations.where((destination) {
      return destination.categories.any(
        (category) => category.id == categoryId,
      );
    }).toList();
  }

  @override
Future<Destination> createDestination(
  Destination destination,
) async {
  final exists = _destinations.any(
    (item) => item.id == destination.id,
  );

  if (exists) {
    throw Exception('ID destinasi sudah digunakan');
  }

  _destinations.add(destination);
  return destination;
}

@override
Future<void> deleteDestination(int id) async {
  final exists = _destinations.any(
    (item) => item.id == id,
  );

  if (!exists) {
    throw Exception('Destinasi tidak ditemukan');
  }

  _destinations.removeWhere(
    (item) => item.id == id,
  );
}

@override
  Future<Destination> updateDestination(
    Destination destination,
  ) async {
    final index = _destinations.indexWhere(
      (item) => item.id == destination.id,
    );

    if (index == -1) {
      throw Exception('Destinasi tidak ditemukan');
    }

    final updatedDestination = Destination(
      id: destination.id,
      location: destination.location,
      name: destination.name,
      description: destination.description,
      fee: destination.fee,
      openingHour: destination.openingHour,
      closingHour: destination.closingHour,
      longitude: destination.longitude,
      latitude: destination.latitude,
      rating: destination.rating,
      categories: List<Category>.from(destination.categories),
      createdAt: _destinations[index].createdAt,
      updatedAt: DateTime.now(),
    );

    _destinations[index] = updatedDestination;

    return updatedDestination;
  }
}