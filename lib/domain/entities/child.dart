class Child {
  final String id;
  final String name;
  final String gender;
  final String location;
  final String? currentLocation; // جديد - الموقع الجغرافي الحالي
  final String educationLevel; // تم تغيير من educationPeriod إلى educationLevel
  final String? profileImagePath;

  // بيانات المدرسة
  final String city;
  final String? district; // جديد - الحي
  final String school;
  final String entryTime;
  final String exitTime;
  final List<String> studyDays;

  // بيانات الخطة
  final List<String> tripTypes;
  final String subscriptionType;

  final DateTime createdAt;
  final bool isActive;

  const Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.location,
    this.currentLocation,
    required this.educationLevel,
    this.profileImagePath,
    required this.city,
    this.district,
    required this.school,
    required this.entryTime,
    required this.exitTime,
    required this.studyDays,
    required this.tripTypes,
    required this.subscriptionType,
    required this.createdAt,
    this.isActive = true,
  });

  // تحويل إلى Map للحفظ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'location': location,
      'currentLocation': currentLocation,
      'educationLevel': educationLevel,
      'profileImagePath': profileImagePath,
      'city': city,
      'district': district,
      'school': school,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'studyDays': studyDays,
      'tripTypes': tripTypes,
      'subscriptionType': subscriptionType,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // إنشاء من Map للاستراد
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      location: map['location'] ?? '',
      currentLocation: map['currentLocation'],
      educationLevel:
          map['educationLevel'] ??
          map['educationPeriod'] ??
          '', // للتوافق العكسي
      profileImagePath: map['profileImagePath'],
      city: map['city'] ?? '',
      district: map['district'],
      school: map['school'] ?? '',
      entryTime: map['entryTime'] ?? '',
      exitTime: map['exitTime'] ?? '',
      studyDays: List<String>.from(map['studyDays'] ?? []),
      tripTypes: List<String>.from(map['tripTypes'] ?? []),
      subscriptionType: map['subscriptionType'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: map['isActive'] ?? true,
    );
  }

  // إنشاء نسخة مع تعديلات
  Child copyWith({
    String? id,
    String? name,
    String? gender,
    String? location,
    String? currentLocation,
    String? educationLevel,
    String? profileImagePath,
    String? city,
    String? district,
    String? school,
    String? entryTime,
    String? exitTime,
    List<String>? studyDays,
    List<String>? tripTypes,
    String? subscriptionType,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      currentLocation: currentLocation ?? this.currentLocation,
      educationLevel: educationLevel ?? this.educationLevel,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      city: city ?? this.city,
      district: district ?? this.district,
      school: school ?? this.school,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      studyDays: studyDays ?? this.studyDays,
      tripTypes: tripTypes ?? this.tripTypes,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Child{id: $id, name: $name, gender: $gender, school: $school}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Child && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
