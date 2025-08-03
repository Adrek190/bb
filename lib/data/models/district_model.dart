// lib/data/models/district_model.dart
import '../../domain/entities/district.dart';

/// District data model for database operations
class DistrictModel {
  final String districtId;
  final String districtName;
  final String cityId;

  const DistrictModel({
    required this.districtId,
    required this.districtName,
    required this.cityId,
  });

  /// Convert from JSON
  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      districtId: json['district_id'] as String,
      districtName: json['district_name'] as String,
      cityId: json['city_id'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'district_id': districtId,
      'district_name': districtName,
      'city_id': cityId,
    };
  }

  /// Convert to domain entity
  District toEntity() {
    return District(
      districtId: districtId,
      districtName: districtName,
      cityId: cityId,
    );
  }

  /// Create from domain entity
  factory DistrictModel.fromEntity(District entity) {
    return DistrictModel(
      districtId: entity.districtId,
      districtName: entity.districtName,
      cityId: entity.cityId,
    );
  }
}
