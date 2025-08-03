// lib/domain/entities/school.dart

/// School entity representing a school within a district - تم التحديث للتصميم المبسط
class School {
  final String schoolId;
  final String schoolName;
  final String schoolType; // government, private, international
  final String educationLevelId; // ID للمرحلة التعليمية
  final String educationLevelName; // اسم المرحلة التعليمية
  final String districtId;
  final String districtName;
  final String cityName;
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

  const School({
    required this.schoolId,
    required this.schoolName,
    required this.schoolType,
    required this.educationLevelId,
    required this.educationLevelName,
    required this.districtId,
    required this.districtName,
    required this.cityName,
    this.fullAddress,
    this.phone,
    this.email,
    this.operatingHoursStart = '07:00',
    this.operatingHoursEnd = '14:00',
    this.workingDays = const [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
    ],
    this.capacity = 500,
    this.currentStudents = 0,
    this.isTransportAvailable = true,
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId;

  @override
  int get hashCode => schoolId.hashCode;

  @override
  String toString() =>
      'School(id: $schoolId, name: $schoolName, educationLevel: $educationLevelName, district: $districtName)';
}
