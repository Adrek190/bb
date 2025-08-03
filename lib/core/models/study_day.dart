class StudyDay {
  final String dayId;
  final String dayNameArabic;
  final String dayNameEnglish;
  final int dayOrder;
  final bool isWeekend;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyDay({
    required this.dayId,
    required this.dayNameArabic,
    required this.dayNameEnglish,
    required this.dayOrder,
    required this.isWeekend,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyDay.fromJson(Map<String, dynamic> json) {
    return StudyDay(
      dayId: json['day_id'] as String,
      dayNameArabic: json['day_name_arabic'] as String,
      dayNameEnglish: json['day_name_english'] as String,
      dayOrder: json['day_order'] as int,
      isWeekend: json['is_weekend'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_id': dayId,
      'day_name_arabic': dayNameArabic,
      'day_name_english': dayNameEnglish,
      'day_order': dayOrder,
      'is_weekend': isWeekend,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StudyDay copyWith({
    String? dayId,
    String? dayNameArabic,
    String? dayNameEnglish,
    int? dayOrder,
    bool? isWeekend,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyDay(
      dayId: dayId ?? this.dayId,
      dayNameArabic: dayNameArabic ?? this.dayNameArabic,
      dayNameEnglish: dayNameEnglish ?? this.dayNameEnglish,
      dayOrder: dayOrder ?? this.dayOrder,
      isWeekend: isWeekend ?? this.isWeekend,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StudyDay(dayId: $dayId, dayNameArabic: $dayNameArabic, dayOrder: $dayOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyDay && other.dayId == dayId;
  }

  @override
  int get hashCode => dayId.hashCode;
}
