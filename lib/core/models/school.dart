class School {
  final String schoolId;
  final String schoolName;
  final String schoolType;
  final String educationLevelId;
  final String districtId;
  final String? fullAddress;
  final String? phone;
  final String? email;
  final DateTime operatingHoursStart;
  final DateTime operatingHoursEnd;
  final List<String> workingDays;
  final int capacity;
  final int currentStudents;
  final bool isTransportAvailable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const School({
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
    required this.currentStudents,
    required this.isTransportAvailable,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['school_id'] as String,
      schoolName: json['school_name'] as String,
      schoolType: json['school_type'] as String? ?? 'government',
      educationLevelId: json['education_level_id'] as String,
      districtId: json['district_id'] as String,
      fullAddress: json['full_address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      operatingHoursStart: _parseTime(json['operating_hours_start']),
      operatingHoursEnd: _parseTime(json['operating_hours_end']),
      workingDays: List<String>.from(
        json['working_days'] ??
            ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday'],
      ),
      capacity: json['capacity'] as int? ?? 500,
      currentStudents: json['current_students'] as int? ?? 0,
      isTransportAvailable: json['is_transport_available'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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

  String get formattedStartTime {
    return '${operatingHoursStart.hour.toString().padLeft(2, '0')}:${operatingHoursStart.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    return '${operatingHoursEnd.hour.toString().padLeft(2, '0')}:${operatingHoursEnd.minute.toString().padLeft(2, '0')}';
  }

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
      'operating_hours_start': formattedStartTime,
      'operating_hours_end': formattedEndTime,
      'working_days': workingDays,
      'capacity': capacity,
      'current_students': currentStudents,
      'is_transport_available': isTransportAvailable,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  School copyWith({
    String? schoolId,
    String? schoolName,
    String? schoolType,
    String? educationLevelId,
    String? districtId,
    String? fullAddress,
    String? phone,
    String? email,
    DateTime? operatingHoursStart,
    DateTime? operatingHoursEnd,
    List<String>? workingDays,
    int? capacity,
    int? currentStudents,
    bool? isTransportAvailable,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return School(
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolType: schoolType ?? this.schoolType,
      educationLevelId: educationLevelId ?? this.educationLevelId,
      districtId: districtId ?? this.districtId,
      fullAddress: fullAddress ?? this.fullAddress,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      operatingHoursStart: operatingHoursStart ?? this.operatingHoursStart,
      operatingHoursEnd: operatingHoursEnd ?? this.operatingHoursEnd,
      workingDays: workingDays ?? this.workingDays,
      capacity: capacity ?? this.capacity,
      currentStudents: currentStudents ?? this.currentStudents,
      isTransportAvailable: isTransportAvailable ?? this.isTransportAvailable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'School(schoolId: $schoolId, schoolName: $schoolName, schoolType: $schoolType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School && other.schoolId == schoolId;
  }

  @override
  int get hashCode => schoolId.hashCode;
}
