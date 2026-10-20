import 'package:waylo/models/category.dart';

class User {
  final int id;
  final String fullname;
  final String username;
  final String password;
  final List<String> districts;
  final List<Category> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasCompletedPreference;
  final String? profileImageBase64;

  const User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.password,
    this.districts = const [],
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
    this.hasCompletedPreference = false,
    this.profileImageBase64,
  });
}
