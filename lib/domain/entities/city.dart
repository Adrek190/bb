// lib/domain/entities/city.dart

/// City entity representing a city in the system
class City {
  final String cityId;
  final String cityName;

  const City({required this.cityId, required this.cityName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId;

  @override
  int get hashCode => cityId.hashCode;

  @override
  String toString() => 'City(id: $cityId, name: $cityName)';
}
