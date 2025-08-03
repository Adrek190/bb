// lib/data/models/school_model.dart
import '../../domain/entities/school.dart';

/// School data model for database operations - تم التحديث للتصميم المبسط
class SchoolModel {
  final String schoolId;
  final String schoolName;
  final String schoolType;
  final String educationLevelId;
  final String districtId;
  final String? fullAddress;
  final String? phone;
  final String? email;
  final String operatingHoursStart;
  final String operatingHoursEnd;
  final List<String> workingDays;
  final int capacity;
  final int currentStudents;
  final bool isTransportAvailable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SchoolModel({
    required this.schoolId,
    required this.schoolName,
    required this.schoolType,
    required this.educationLevelId,
    required this.districtId,
    this.fullAddress,
    this.phone,
    this.email,
    required this.operatingHoursStart,
    required this.operatingHoursEnd,
    required this.workingDays,
    required this.capacity,
    this.currentStudents = 0,
    required this.isTransportAvailable,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from JSON (مع معلومات إضافية من الجداول المرتبطة)
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      schoolId: json['school_id'] as String,
      schoolName: json['school_name'] as String,
      schoolType: json['school_type'] as String,
      educationLevelId: json['education_level_id'] as String,
      districtId: json['district_id'] as String,
      fullAddress: json['full_address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      operatingHoursStart: json['operating_hours_start'] as String,
      operatingHoursEnd: json['operating_hours_end'] as String,
      workingDays: List<String>.from(json['working_days'] as List? ?? []),
      capacity: json['capacity'] as int,
      currentStudents: json['current_students'] as int? ?? 0,
      isTransportAvailable: json['is_transport_available'] as bool,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'school_name': schoolName,
      'school_type': schoolType,
      'education_level_id': educationLevelId,
      'district_id': districtId,
      'full_address': fullAddress,
      'phone': phone,
      'email': email,
      'operating_hours_start': operatingHoursStart,
      'operating_hours_end': operatingHoursEnd,
      'working_days': workingDays,
      'capacity': capacity,
      'current_students': currentStudents,
      'is_transport_available': isTransportAvailable,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity (يتطلب معلومات إضافية من الاستعلام)
  School toEntity({
    required String educationLevelName,
    required String districtName,
    required String cityName,
  }) {
    return School(
      schoolId: schoolId,
      schoolName: schoolName,
      schoolType: schoolType,
      educationLevelId: educationLevelId,
      educationLevelName: educationLevelName,
      districtId: districtId,
      districtName: districtName,
      cityName: cityName,
      fullAddress: fullAddress,
      phone: phone,
      email: email,
      operatingHoursStart: operatingHoursStart,
      operatingHoursEnd: operatingHoursEnd,
      workingDays: workingDays,
      capacity: capacity,
      currentStudents: currentStudents,
      isTransportAvailable: isTransportAvailable,
      isActive: isActive,
    );
  }

  /// Create from domain entity
  factory SchoolModel.fromEntity(School entity) {
    final now = DateTime.now();
    return SchoolModel(
      schoolId: entity.schoolId,
      schoolName: entity.schoolName,
      schoolType: entity.schoolType,
      educationLevelId: entity.educationLevelId,
      districtId: entity.districtId,
      fullAddress: entity.fullAddress,
      phone: entity.phone,
      email: entity.email,
      operatingHoursStart: entity.operatingHoursStart,
      operatingHoursEnd: entity.operatingHoursEnd,
      workingDays: entity.workingDays,
      capacity: entity.capacity,
      currentStudents: entity.currentStudents,
      isTransportAvailable: entity.isTransportAvailable,
      isActive: entity.isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolModel &&
        other.schoolId == schoolId &&
        other.schoolName == schoolName &&
        other.schoolType == schoolType &&
        other.educationLevelId == educationLevelId &&
        other.districtId == districtId;
  }

  @override
  int get hashCode {
    return Object.hash(
      schoolId,
      schoolName,
      schoolType,
      educationLevelId,
      districtId,
    );
  }

  @override
  String toString() {
    return 'SchoolModel(schoolId: $schoolId, schoolName: $schoolName, schoolType: $schoolType, educationLevelId: $educationLevelId, districtId: $districtId)';
  }
}
