import 'package:waylo/models/category.dart';
import 'package:waylo/models/location.dart';

class Destination {
  final int id;
  final Location location;
  final String name;
  final String description;
  final List<Category> categories;
  final double? fee;
  final String? openingHour;
  final String? closingHour;
  final double? longitude;
  final double? latitude;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Destination({
    required this.id,
    required this.location,
    required this.name,
    required this.description,
    this.categories = const [],
    this.fee,
    this.openingHour,
    this.closingHour,
    this.longitude,
    this.latitude,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });
}