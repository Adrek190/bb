class City {
  final String cityId;
  final String cityName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const City({
    required this.cityId,
    required this.cityName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityId: json['city_id'] as String,
      cityName: json['city_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_id': cityId,
      'city_name': cityName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  City copyWith({
    String? cityId,
    String? cityName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return City(
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'City(cityId: $cityId, cityName: $cityName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.cityId == cityId;
  }

  @override
  int get hashCode => cityId.hashCode;
}
