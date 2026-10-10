class Timezone {
  final int id;
  final String cityName;
  final String timeZoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Timezone({
    required this.id,
    required this.cityName,
    required this.timeZoneId,
    required this.createdAt,
    required this.updatedAt,
  });
}
