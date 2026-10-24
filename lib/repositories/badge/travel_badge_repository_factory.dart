import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waylo/repositories/badge/travel_badge_repository.dart';
import 'package:waylo/repositories/badge/travel_badge_supabase_repository.dart';
import 'package:waylo/service/session_storage.dart';

class TravelBadgeRepositoryFactory {
  static TravelBadgeRepository create(
    SupabaseClient supabase,
    SessionStorage sessionStorage,
  ) {
    return TravelBadgeSupabaseRepository(
      supabase,
      sessionStorage,
    );
  }
}