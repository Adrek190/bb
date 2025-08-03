// lib/data/models/city_model.dart
import '../../domain/entities/city.dart';

/// City data model for database operations
class CityModel {
  final String cityId;
  final String cityName;

  const CityModel({required this.cityId, required this.cityName});

  /// Convert from JSON
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: json['city_id'] as String,
      cityName: json['city_name'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'city_id': cityId, 'city_name': cityName};
  }

  /// Convert to domain entity
  City toEntity() {
    return City(cityId: cityId, cityName: cityName);
  }

  /// Create from domain entity
  factory CityModel.fromEntity(City entity) {
    return CityModel(cityId: entity.cityId, cityName: entity.cityName);
  }
}
