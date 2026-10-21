
import 'package:supabase_flutter/supabase_flutter.dart';
import 'district_repository.dart';
import 'district_supabase_repository.dart';

class DistrictRepositoryFactory {
  static DistrictRepository create() {
    return DistrictSupabaseRepository(
      Supabase.instance.client,
    );
  }
}
