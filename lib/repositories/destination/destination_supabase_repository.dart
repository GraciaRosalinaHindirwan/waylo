import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' hide Category;

import 'package:waylo/models/category.dart';
import 'package:waylo/models/coordinate.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/models/destinationImage.dart';
import 'package:waylo/models/location.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';

class DestinationSupabaseRepository implements DestinationRepository {
  final SupabaseClient _supabase; //untuk komunikasi dengan supabase 

  //constructor 
  DestinationSupabaseRepository(this._supabase);
  
  @override
  Future<List<Destination>> getAllDestinations() async {
    final response = await _supabase
    .from('destinations')
    .select('''
      *,
      subdistrict:subdistrict!destinations_postal_code_subdistrict_fkey(
        postal_code,
        name,
        created_at,
        updated_at,
        district:district!subdistrict_id_district_fkey(
          id,
          name,
          created_at,
          updated_at,
          province:province!district_id_province_fkey(
            id,
            name,
            created_at,
            updated_at
          )
        )
      ),
      images:images!images_id_destination_fkey(*),
      destination_category(
        category(*)
      )
    ''');

  debugPrint('DATA RELASI: $response');

    //ubah hasil JSON List<Destination> 
    return (response as List)
        .map((row) => _mapDestination(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  //buat detail page 
  @override
  Future<Destination?> getDestinationById(int id) async {
    final response = await _supabase
        .from('destinations')
        .select('''
          *,
          subdistrict:subdistrict!destinations_postal_code_subdistrict_fkey(
            postal_code,
            name,
            created_at,
            updated_at,
            district:district!subdistrict_id_district_fkey(
              id,
              name,
              created_at,
              updated_at,
              province:province!district_id_province_fkey(
                id,
                name,
                created_at,
                updated_at
              )
            )
          ),
          images(*),
          destination_category(
            category(*)
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return _mapDestination(Map<String, dynamic>.from(response));
  }

  @override
  Future<List<Destination>> getDestinationsByCategory(
    int categoryId,
  ) async {
    final response = await _supabase
        .from('destinations')
        .select('''
          *,
          subdistrict:subdistrict!destinations_postal_code_subdistrict_fkey(
            postal_code,
            name,
            created_at,
            updated_at,
            district:district!subdistrict_id_district_fkey(
              id,
              name,
              created_at,
              updated_at,
              province:province!district_id_province_fkey(
                id,
                name,
                created_at,
                updated_at
              )
            )
          ),
          images(*),
          destination_category!inner(
            id_category,
            category(*)
          )
        ''')
        .eq('destination_category.id_category', categoryId);

    return (response as List)
        .map((row) => _mapDestination(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  
  //mengubah 1 baris data supabase menjadi object model Destination 
  Destination _mapDestination(Map<String, dynamic> row) {
    final subdistrict =
        Map<String, dynamic>.from(row['subdistrict'] as Map);
    final district =
        Map<String, dynamic>.from(subdistrict['district'] as Map);
    final province =
        Map<String, dynamic>.from(district['province'] as Map);

    final imageRows = (row['images'] as List? ?? []);
    final relationRows =
        (row['destination_category'] as List? ?? []);

    final categories = relationRows
        .where((relation) => relation['category'] != null)
        .map((relation) {
          final category =
              Map<String, dynamic>.from(relation['category'] as Map);

          return Category(
            id: (category['id'] as num).toInt(),
            name: category['name'] as String,
            createdAt: DateTime.parse(category['created_at'] as String),
            updatedAt: DateTime.parse(category['updated_at'] as String),
          );
        })
        .toList();

    final images = imageRows.map((item) {
      final image = Map<String, dynamic>.from(item);

      return DestinationImage(
        id: (image['id'] as num).toInt(),
        destinationId: (image['id_destination'] as num).toInt(),
        isBanner: image['is_banner'] as bool,
        imageUrl: image['image_url'] as String? ?? '',
        createdAt: DateTime.parse(image['created_at'] as String),
        updatedAt: DateTime.parse(image['updated_at'] as String),
      );
    }).toList();

    return Destination(
      id: (row['id'] as num).toInt(),
      name: row['name'] as String,
      description: row['description'] as String,
      fee: (row['fee'] as num?)?.toDouble(),
      openingHour: row['opening_hour'] as String?,
      closingHour: row['closing_hour'] as String?,
      rating: (row['rating'] as num).toDouble(),
      coordinate: Coordinate(
        latitude: (row['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (row['longitude'] as num?)?.toDouble() ?? 0,
      ),
      location: Location(
        idProvince: (province['id'] as num).toInt(),
        idDistrict: (district['id'] as num).toInt(),
        postalCode: (subdistrict['postal_code'] as num).toInt(),
        provinceName: province['name'] as String,
        districtName: district['name'] as String,
        subdistrictName: subdistrict['name'] as String,
        provinceCreatedAt:
            DateTime.parse(province['created_at'] as String),
        provinceUpdatedAt:
            DateTime.parse(province['updated_at'] as String),
        districtCreatedAt:
            DateTime.parse(district['created_at'] as String),
        districtUpdatedAt:
            DateTime.parse(district['updated_at'] as String),
        subdistrictCreatedAt:
            DateTime.parse(subdistrict['created_at'] as String),
        subdistrictUpdatedAt:
            DateTime.parse(subdistrict['updated_at'] as String),
      ),
      categories: categories,
      images: images,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Future<Destination> createDestination(Destination destination) {
    throw UnimplementedError('Create belum diimplementasikan.');
  }

  @override
  Future<Destination> updateDestination(Destination destination) {
    throw UnimplementedError('Update belum diimplementasikan.');
  }

  @override
  Future<void> deleteDestination(int id) {
    throw UnimplementedError('Delete belum diimplementasikan.');
  }
}
