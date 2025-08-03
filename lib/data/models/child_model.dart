// lib/data/models/child_model.dart
import '../../domain/entities/child.dart';

/// Child data model for database operations
class ChildModel {
  final String childId;
  final String childName;
  final String childLocation;
  final String? profileImagePath;
  final String? profileImageUrl;
  final String? currentLocation;
  final String gender;
  final String educationLevel;
  final String? educationLevelId;
  final String parentId;
  final String schoolId;
  final String districtId;
  final String entryTime;
  final String exitTime;
  final List<String> studyDays;
  final List<String> tripTypes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const ChildModel({
    required this.childId,
    required this.childName,
    required this.childLocation,
    this.profileImagePath,
    this.profileImageUrl,
    this.currentLocation,
    required this.gender,
    required this.educationLevel,
    this.educationLevelId,
    required this.parentId,
    required this.schoolId,
    required this.districtId,
    required this.entryTime,
    required this.exitTime,
    required this.studyDays,
    required this.tripTypes,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// Convert from JSON
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      childId: json['child_id'] as String,
      childName: json['child_name'] as String,
      childLocation: json['child_location'] as String,
      profileImagePath: json['profile_image_path'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      currentLocation: json['current_location'] as String?,
      gender: json['gender'] as String,
      educationLevel: json['education_level'] as String,
      educationLevelId: json['education_level_id'] as String?,
      parentId: json['parent_id'] as String,
      schoolId: json['school_id'] as String,
      districtId: json['district_id'] as String,
      entryTime: json['entry_time'] as String,
      exitTime: json['exit_time'] as String,
      studyDays: _parseJsonArray(json['study_days']),
      tripTypes: _parseJsonArray(json['trip_types']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'child_name': childName,
      'child_location': childLocation,
      'profile_image_path': profileImagePath,
      'profile_image_url': profileImageUrl,
      'current_location': currentLocation,
      'gender': gender,
      'education_level': educationLevel,
      'education_level_id': educationLevelId,
      'parent_id': parentId,
      'school_id': schoolId,
      'district_id': districtId,
      'entry_time': entryTime,
      'exit_time': exitTime,
      'study_days': studyDays,
      'trip_types': tripTypes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Convert to domain entity
  Child toEntity() {
    return Child(
      id: childId,
      name: childName,
      gender: gender,
      location: childLocation,
      currentLocation: currentLocation,
      educationLevel: educationLevel,
      profileImagePath: profileImagePath,
      city: '', // Will be filled from relationships
      district: '', // Will be filled from relationships
      school: '', // Will be filled from relationships
      entryTime: entryTime,
      exitTime: exitTime,
      studyDays: studyDays,
      tripTypes: tripTypes,
      subscriptionType: 'شهري', // Default value
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  /// Create from domain entity
  factory ChildModel.fromEntity(Child entity) {
    final now = DateTime.now();
    return ChildModel(
      childId: entity.id,
      childName: entity.name,
      childLocation: entity.location,
      profileImagePath: entity.profileImagePath,
      currentLocation: entity.currentLocation,
      gender: entity.gender,
      educationLevel: entity.educationLevel,
      parentId: '', // Will be set from context
      schoolId: '', // Will be resolved from school name
      districtId: '', // Will be resolved from district name
      entryTime: entity.entryTime,
      exitTime: entity.exitTime,
      studyDays: entity.studyDays,
      tripTypes: entity.tripTypes,
      createdAt: entity.createdAt,
      updatedAt: now,
      isActive: entity.isActive,
    );
  }

  /// Helper method to parse JSON array
  static List<String> _parseJsonArray(dynamic jsonData) {
    if (jsonData == null) return [];
    if (jsonData is List) {
      return jsonData.map((item) => item.toString()).toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildModel &&
        other.childId == childId &&
        other.childName == childName &&
        other.parentId == parentId;
  }

  @override
  int get hashCode => Object.hash(childId, childName, parentId);

  @override
  String toString() {
    return 'ChildModel(id: $childId, name: $childName, school: $schoolId)';
  }
}
