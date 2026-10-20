import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/repositories/user/user_repository.dart';
import 'package:waylo/repositories/user/user_supabase_repository.dart';
import 'package:waylo/service/session_storage.dart';

// petugas yang menyiapkan pekerja, 
// kalau diubah nanti cukup di sini saja, 
// tidak perlu diubah di tempat lain
class UserRepositoryFactory {
  static Future<UserRepository> create() async {
    return UserSupabaseRepository(
      Supabase.instance.client,
      SessionStorage(),  
    );
  }
}
