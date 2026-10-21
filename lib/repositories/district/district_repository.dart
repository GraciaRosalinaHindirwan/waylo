
class District {
  final int id;
  final String name;

  const District({
    required this.id,
    required this.name,
  });

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
    );
  }
}

abstract class DistrictRepository {
  Future<List<District>> getAllDistricts();
}
