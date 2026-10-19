
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:waylo/models/user.dart';
import 'package:waylo/models/category.dart';
import 'package:waylo/repositories/user/user_repository.dart';

class UserSupabaseRepository implements UserRepository {
  final SupabaseClient _supabase;

  UserSupabaseRepository(this._supabase);

  @override
  Future<void> initializeDummyUsers() async {}

  // Mengambil profil berdasarkan ID.
  @override
  Future<User?> getUserById(int id) async {
    final response = await _supabase
        .from('users')
        .select(
          'id, fullname, username, created_at, updated_at, profile_image_url',
        )
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return _mapUser(response);
  }

  // Jangan gunakan method ini untuk memverifikasi password.
  // Login dilakukan melalui Edge Function.
  @override
  Future<User?> getUserByUsername(String username) async {
    final response = await _supabase
        .from('users')
        .select(
          'id, fullname, username, created_at, updated_at, profile_image_url',
        )
        .ilike('username', username)
        .maybeSingle();

    if (response == null) return null;

    return _mapUser(response);
  }

  // Registrasi melalui Edge Function.
  @override
  Future<User> createUser(User user) async {
    final response = await _supabase.functions.invoke(
      'auth-user',
      body: {
        'action': 'register',
        'fullname': user.fullname,
        'username': user.username,
        'password': user.password,
      },
    );

    final data = response.data;

    if (response.status != 201 ||
        data is! Map ||
        data['user'] is! Map) {
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : 'Registrasi gagal';

      throw Exception(message);
    }

    final row = Map<String, dynamic>.from(data['user'] as Map);
    return _mapUser(row);
  }

  @override
  Future<User> updateUser(User user) async {
    final response = await _supabase
        .from('users')
        .update({
          'fullname': user.fullname,
          'username': user.username,
        })
        .eq('id', user.id)
        .select(
          'id, fullname, username, created_at, updated_at, profile_image_url',
        )
        .single();

    return _mapUser(response);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _supabase.from('users').delete().eq('id', id);
  }

  User _mapUser(Map<String, dynamic> row) {
    return User(
      id: (row['id'] as num).toInt(),
      fullname: row['fullname'] as String,
      username: row['username'] as String,
      password: '',
      destinations: const <String>[],
      categories: const <Category>[],
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      hasCompletedPreference: false,
      profileImageBase64: null,
    );
  }
}
