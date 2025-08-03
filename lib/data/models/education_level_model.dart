import '../../domain/entities/education_level.dart';

/// Data model for EducationLevel entity - تم التحديث للتصميم المبسط
/// Represents database table structure for education levels
class EducationLevelModel {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationLevelModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (from Supabase/PostgreSQL)
  factory EducationLevelModel.fromJson(Map<String, dynamic> json) {
    return EducationLevelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase/PostgreSQL)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  EducationLevel toEntity() {
    return EducationLevel(
      levelId: id,
      levelName: name,
      levelNameEn: nameEn,
      description: description,
      displayOrder: sortOrder,
      isActive: isActive,
    );
  }

  /// Create from domain entity
  factory EducationLevelModel.fromEntity(EducationLevel entity) {
    final now = DateTime.now();
    return EducationLevelModel(
      id: entity.levelId,
      name: entity.levelName,
      nameEn: entity.levelNameEn,
      description: entity.description,
      sortOrder: entity.displayOrder,
      isActive: entity.isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationLevelModel &&
        other.id == id &&
        other.name == name &&
        other.nameEn == nameEn &&
        other.description == description &&
        other.sortOrder == sortOrder &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, nameEn, description, sortOrder, isActive);
  }

  @override
  String toString() {
    return 'EducationLevelModel(id: $id, name: $name, nameEn: $nameEn, sortOrder: $sortOrder, isActive: $isActive)';
  }
}
