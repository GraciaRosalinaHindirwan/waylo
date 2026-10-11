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
}