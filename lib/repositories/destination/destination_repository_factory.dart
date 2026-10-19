import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';
import 'package:waylo/repositories/destination/destination_supabase_repository.dart';


class DestinationRepositoryFactory {
  static DestinationRepository create() {
    return DestinationSupabaseRepository(
      Supabase.instance.client, 
    );
  }
}