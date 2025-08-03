// lib/domain/entities/education_level.dart

/// Education Level domain entity - تم التحديث للتصميم المبسط
class EducationLevel {
  final String levelId;
  final String levelName;
  final String? levelNameEn;
  final String? description;
  final int displayOrder;
  final bool isActive;

  const EducationLevel({
    required this.levelId,
    required this.levelName,
    this.levelNameEn,
    this.description,
    required this.displayOrder,
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EducationLevel &&
          runtimeType == other.runtimeType &&
          levelId == other.levelId;

  @override
  int get hashCode => levelId.hashCode;

  @override
  String toString() =>
      'EducationLevel(levelId: $levelId, levelName: $levelName)';
}
