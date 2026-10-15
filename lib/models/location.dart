class Location {
  // Province
  final int idProvince;
  final int idCountry;
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
    required this.idCountry,
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
}