import 'package:waylo/models/category.dart';

class User{
  final int id; 
  final String fullname; 
  final String username;
  final String password; 
  final List<String> destinations; 
   final List<Category> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.password,
    this.destinations = const [],
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt
  }); 
}