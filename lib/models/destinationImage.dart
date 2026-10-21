class DestinationImage {
  final int id;
  final int destinationId;
  final bool isBanner;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DestinationImage({
    required this.id,
    required this.destinationId,
    required this.isBanner,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'isBanner': isBanner,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DestinationImage.fromJson(Map<String, dynamic> json) {
    return DestinationImage(
      id: (json['id'] as num).toInt(),
      destinationId: (json['destinationId'] as num).toInt(),
      isBanner: json['isBanner'] as bool,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}