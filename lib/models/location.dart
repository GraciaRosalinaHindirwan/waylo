class Location {
  // Province
  final int idProvince;
  final String provinceName;

  // District
  final int idDistrict;
  final String districtName;

  // Subdistrict
  final int postalCode;
  final String subdistrictName;

  // Timestamps
  final DateTime provinceCreatedAt;
  final DateTime provinceUpdatedAt;
  final DateTime districtCreatedAt;
  final DateTime districtUpdatedAt;
  final DateTime subdistrictCreatedAt;
  final DateTime subdistrictUpdatedAt;

  const Location({
    required this.idProvince,
    required this.provinceName,
    required this.idDistrict,
    required this.districtName,
    required this.postalCode,
    required this.subdistrictName,
    required this.provinceCreatedAt,
    required this.provinceUpdatedAt,
    required this.districtCreatedAt,
    required this.districtUpdatedAt,
    required this.subdistrictCreatedAt,
    required this.subdistrictUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'idProvince': idProvince,
      'provinceName': provinceName,
      'idDistrict': idDistrict,
      'districtName': districtName,
      'postalCode': postalCode,
      'subdistrictName': subdistrictName,
      'provinceCreatedAt': provinceCreatedAt.toIso8601String(),
      'provinceUpdatedAt': provinceUpdatedAt.toIso8601String(),
      'districtCreatedAt': districtCreatedAt.toIso8601String(),
      'districtUpdatedAt': districtUpdatedAt.toIso8601String(),
      'subdistrictCreatedAt': subdistrictCreatedAt.toIso8601String(),
      'subdistrictUpdatedAt': subdistrictUpdatedAt.toIso8601String(),
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      idProvince: (json['idProvince'] as num).toInt(),
      provinceName: json['provinceName'] as String,
      idDistrict: (json['idDistrict'] as num).toInt(),
      districtName: json['districtName'] as String,
      postalCode: (json['postalCode'] as num).toInt(),
      subdistrictName: json['subdistrictName'] as String,
      provinceCreatedAt:
          DateTime.parse(json['provinceCreatedAt'] as String),
      provinceUpdatedAt:
          DateTime.parse(json['provinceUpdatedAt'] as String),
      districtCreatedAt:
          DateTime.parse(json['districtCreatedAt'] as String),
      districtUpdatedAt:
          DateTime.parse(json['districtUpdatedAt'] as String),
      subdistrictCreatedAt:
          DateTime.parse(json['subdistrictCreatedAt'] as String),
      subdistrictUpdatedAt:
          DateTime.parse(json['subdistrictUpdatedAt'] as String),
    );
  }
}