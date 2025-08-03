class TransportPlan {
  final String planId;
  final String planNameArabic;
  final String planNameEnglish;
  final String planCode;
  final String? descriptionArabic;
  final String? descriptionEnglish;
  final Map<String, dynamic> tripTypes;
  final double monthlyPrice;
  final double setupFee;
  final Map<String, dynamic>? features;
  final int maxDistanceKm;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportPlan({
    required this.planId,
    required this.planNameArabic,
    required this.planNameEnglish,
    required this.planCode,
    this.descriptionArabic,
    this.descriptionEnglish,
    required this.tripTypes,
    required this.monthlyPrice,
    required this.setupFee,
    this.features,
    required this.maxDistanceKm,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportPlan.fromJson(Map<String, dynamic> json) {
    return TransportPlan(
      planId: json['plan_id'] as String,
      planNameArabic: json['plan_name_arabic'] as String,
      planNameEnglish: json['plan_name_english'] as String,
      planCode: json['plan_code'] as String,
      descriptionArabic: json['description_arabic'] as String?,
      descriptionEnglish: json['description_english'] as String?,
      tripTypes: Map<String, dynamic>.from(json['trip_types'] ?? {}),
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      setupFee: (json['setup_fee'] as num?)?.toDouble() ?? 0.0,
      features: json['features'] != null
          ? Map<String, dynamic>.from(json['features'])
          : null,
      maxDistanceKm: json['max_distance_km'] as int? ?? 50,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'plan_name_arabic': planNameArabic,
      'plan_name_english': planNameEnglish,
      'plan_code': planCode,
      'description_arabic': descriptionArabic,
      'description_english': descriptionEnglish,
      'trip_types': tripTypes,
      'monthly_price': monthlyPrice,
      'setup_fee': setupFee,
      'features': features,
      'max_distance_km': maxDistanceKm,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TransportPlan copyWith({
    String? planId,
    String? planNameArabic,
    String? planNameEnglish,
    String? planCode,
    String? descriptionArabic,
    String? descriptionEnglish,
    Map<String, dynamic>? tripTypes,
    double? monthlyPrice,
    double? setupFee,
    Map<String, dynamic>? features,
    int? maxDistanceKm,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportPlan(
      planId: planId ?? this.planId,
      planNameArabic: planNameArabic ?? this.planNameArabic,
      planNameEnglish: planNameEnglish ?? this.planNameEnglish,
      planCode: planCode ?? this.planCode,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      tripTypes: tripTypes ?? this.tripTypes,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      setupFee: setupFee ?? this.setupFee,
      features: features ?? this.features,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransportPlan(planId: $planId, planNameArabic: $planNameArabic, monthlyPrice: $monthlyPrice, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransportPlan && other.planId == planId;
  }

  @override
  int get hashCode => planId.hashCode;
}
