enum Gender {
  male, // ذكر
  female, // أنثى
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  String get value {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }

  static Gender fromString(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}

class Child {
  final String childId;
  final String childName;
  final String childLocation;
  final String? profileImagePath;
  final Gender gender;
  final String educationLevel;
  final String parentId;
  final String schoolId;
  final String districtId;
  final DateTime entryTime;
  final DateTime exitTime;
  final Map<String, dynamic> studyDays;
  final Map<String, dynamic> tripTypes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? educationLevelId;
  final String? profileImageUrl;
  final String? currentLocation;

  const Child({
    required this.childId,
    required this.childName,
    required this.childLocation,
    this.profileImagePath,
    required this.gender,
    required this.educationLevel,
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
    this.educationLevelId,
    this.profileImageUrl,
    this.currentLocation,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['child_id'] as String,
      childName: json['child_name'] as String,
      childLocation: json['child_location'] as String,
      profileImagePath: json['profile_image_path'] as String?,
      gender: GenderExtension.fromString(json['gender'] as String),
      educationLevel: json['education_level'] as String,
      parentId: json['parent_id'] as String,
      schoolId: json['school_id'] as String,
      districtId: json['district_id'] as String,
      entryTime: _parseTime(json['entry_time']),
      exitTime: _parseTime(json['exit_time']),
      studyDays: Map<String, dynamic>.from(json['study_days'] ?? {}),
      tripTypes: Map<String, dynamic>.from(json['trip_types'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      educationLevelId: json['education_level_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      currentLocation: json['current_location'] as String?,
    );
  }

  static DateTime _parseTime(dynamic timeValue) {
    if (timeValue == null) return DateTime(1970, 1, 1, 7, 0); // Default 07:00
    if (timeValue is String) {
      // Parse time string like "07:00:00"
      final parts = timeValue.split(':');
      final hour = int.tryParse(parts[0]) ?? 7;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(1970, 1, 1, hour, minute);
    }
    return DateTime(1970, 1, 1, 7, 0);
  }

  String get formattedEntryTime {
    return '${entryTime.hour.toString().padLeft(2, '0')}:${entryTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedExitTime {
    return '${exitTime.hour.toString().padLeft(2, '0')}:${exitTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'child_name': childName,
      'child_location': childLocation,
      'profile_image_path': profileImagePath,
      'gender': gender.value,
      'education_level': educationLevel,
      'parent_id': parentId,
      'school_id': schoolId,
      'district_id': districtId,
      'entry_time': formattedEntryTime,
      'exit_time': formattedExitTime,
      'study_days': studyDays,
      'trip_types': tripTypes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'education_level_id': educationLevelId,
      'profile_image_url': profileImageUrl,
      'current_location': currentLocation,
    };
  }

  Child copyWith({
    String? childId,
    String? childName,
    String? childLocation,
    String? profileImagePath,
    Gender? gender,
    String? educationLevel,
    String? parentId,
    String? schoolId,
    String? districtId,
    DateTime? entryTime,
    DateTime? exitTime,
    Map<String, dynamic>? studyDays,
    Map<String, dynamic>? tripTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? educationLevelId,
    String? profileImageUrl,
    String? currentLocation,
  }) {
    return Child(
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      childLocation: childLocation ?? this.childLocation,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      gender: gender ?? this.gender,
      educationLevel: educationLevel ?? this.educationLevel,
      parentId: parentId ?? this.parentId,
      schoolId: schoolId ?? this.schoolId,
      districtId: districtId ?? this.districtId,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      studyDays: studyDays ?? this.studyDays,
      tripTypes: tripTypes ?? this.tripTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      educationLevelId: educationLevelId ?? this.educationLevelId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  String toString() {
    return 'Child(childId: $childId, childName: $childName, gender: ${gender.displayName}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Child && other.childId == childId;
  }

  @override
  int get hashCode => childId.hashCode;
}
