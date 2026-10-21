import 'package:waylo/models/category.dart';
import 'package:waylo/models/coordinate.dart';
import 'package:waylo/models/destinationImage.dart';
import 'package:waylo/models/location.dart';

class Destination {
  final int id;
  final List<DestinationImage> images;
  final Location location;
  final String name;
  final String description;
  final List<Category> categories;
  final double? fee;
  final String? openingHour;
  final String? closingHour;
  final Coordinate coordinate;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Destination({
    required this.id,
    required this.images,
    required this.location,
    required this.name,
    required this.description,
    this.categories = const [],
    this.fee,
    this.openingHour,
    this.closingHour,
    required this.coordinate,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  // Mengubah objek Destination menjadi Map untuk disimpan di Hive.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'images': images.map((image) => image.toJson()).toList(),
      'location': location.toJson(),
      'name': name,
      'description': description,
      'categories': categories.map((category) => category.toJson()).toList(),
      'fee': fee,
      'openingHour': openingHour,
      'closingHour': closingHour,
      'coordinate': coordinate.toJson(),
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Membentuk kembali objek Destination dari data Hive.
  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: (json['id'] as num).toInt(),
      images: (json['images'] as List<dynamic>)
          .map(
            (image) => DestinationImage.fromJson(
              Map<String, dynamic>.from(image as Map),
            ),
          )
          .toList(),
      location: Location.fromJson(
        Map<String, dynamic>.from(json['location'] as Map),
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map(
            (category) => Category.fromJson(
              Map<String, dynamic>.from(category as Map),
            ),
          )
          .toList(),
      fee: (json['fee'] as num?)?.toDouble(),
      openingHour: json['openingHour'] as String?,
      closingHour: json['closingHour'] as String?,
      coordinate: Coordinate.fromJson(
        Map<String, dynamic>.from(json['coordinate'] as Map),
      ),
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}