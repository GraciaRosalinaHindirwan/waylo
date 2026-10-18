enum BadgeType {
  destinationVisit,
  categoryVisit,
  specificDestination,
  itineraryCreated,
}

class TravelBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int targetCount;
  final BadgeType type;

  const TravelBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.targetCount = 1,
    required this.type,
  });
}
