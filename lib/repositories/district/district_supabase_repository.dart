
import 'package:supabase_flutter/supabase_flutter.dart';
import 'district_repository.dart';

class DistrictSupabaseRepository implements DistrictRepository {
  final SupabaseClient _supabase;

  DistrictSupabaseRepository(this._supabase);

  @override
  Future<List<District>> getAllDistricts() async {
    final response = await _supabase
        .from('district')
        .select('id, name')
        .order('name');

    return (response as List)
        .map((row) => District.fromMap(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }
}
