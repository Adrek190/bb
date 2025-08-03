// lib/domain/entities/study_day.dart

/// Study Day domain entity
class StudyDay {
  final String dayId;
  final String dayNameArabic;
  final String dayNameEnglish;
  final int dayOrder;
  final bool isWeekend;
  final bool isActive;

  const StudyDay({
    required this.dayId,
    required this.dayNameArabic,
    required this.dayNameEnglish,
    required this.dayOrder,
    this.isWeekend = false,
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyDay &&
          runtimeType == other.runtimeType &&
          dayId == other.dayId;

  @override
  int get hashCode => dayId.hashCode;

  @override
  String toString() => 'StudyDay(dayId: $dayId, dayNameArabic: $dayNameArabic)';
}
