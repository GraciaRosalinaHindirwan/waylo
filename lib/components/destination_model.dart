
class Destination {
  final String id;
  final String name;
  final String city;
  final String imageUrl;
  final double rating;
  final double? distanceKm;

  const Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.imageUrl,
    required this.rating,
    this.distanceKm,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}
