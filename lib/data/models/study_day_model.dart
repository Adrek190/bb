import '../../domain/entities/study_day.dart';

/// Data model for StudyDay entity
/// Represents database table structure for study days
class StudyDayModel {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final int dayOrder;
  final bool isWeekend;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyDayModel({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.dayOrder,
    required this.isWeekend,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (from Supabase/PostgreSQL)
  factory StudyDayModel.fromJson(Map<String, dynamic> json) {
    return StudyDayModel(
      id: json['id'] as String,
      nameArabic: json['name_arabic'] as String,
      nameEnglish: json['name_english'] as String,
      dayOrder: json['day_order'] as int,
      isWeekend: json['is_weekend'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase/PostgreSQL)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'day_order': dayOrder,
      'is_weekend': isWeekend,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  StudyDay toEntity() {
    return StudyDay(
      dayId: id,
      dayNameArabic: nameArabic,
      dayNameEnglish: nameEnglish,
      dayOrder: dayOrder,
      isWeekend: isWeekend,
      isActive: isActive,
    );
  }

  /// Create from domain entity
  factory StudyDayModel.fromEntity(StudyDay entity) {
    final now = DateTime.now();
    return StudyDayModel(
      id: entity.dayId,
      nameArabic: entity.dayNameArabic,
      nameEnglish: entity.dayNameEnglish,
      dayOrder: entity.dayOrder,
      isWeekend: entity.isWeekend,
      isActive: entity.isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyDayModel &&
        other.id == id &&
        other.nameArabic == nameArabic &&
        other.nameEnglish == nameEnglish &&
        other.dayOrder == dayOrder &&
        other.isWeekend == isWeekend &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nameArabic,
      nameEnglish,
      dayOrder,
      isWeekend,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'StudyDayModel(id: $id, nameArabic: $nameArabic, nameEnglish: $nameEnglish, dayOrder: $dayOrder, isWeekend: $isWeekend, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
