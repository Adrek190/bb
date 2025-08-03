// lib/domain/entities/district.dart

/// District entity representing a district within a city
class District {
  final String districtId;
  final String districtName;
  final String cityId;

  const District({
    required this.districtId,
    required this.districtName,
    required this.cityId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is District &&
          runtimeType == other.runtimeType &&
          districtId == other.districtId;

  @override
  int get hashCode => districtId.hashCode;

  @override
  String toString() =>
      'District(id: $districtId, name: $districtName, cityId: $cityId)';
}
