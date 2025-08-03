class District {
  final String districtId;
  final String districtName;
  final String cityId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const District({
    required this.districtId,
    required this.districtName,
    required this.cityId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtId: json['district_id'] as String,
      districtName: json['district_name'] as String,
      cityId: json['city_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'district_id': districtId,
      'district_name': districtName,
      'city_id': cityId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  District copyWith({
    String? districtId,
    String? districtName,
    String? cityId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return District(
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      cityId: cityId ?? this.cityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'District(districtId: $districtId, districtName: $districtName, cityId: $cityId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District && other.districtId == districtId;
  }

  @override
  int get hashCode => districtId.hashCode;
}
