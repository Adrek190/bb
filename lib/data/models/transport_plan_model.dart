import '../../domain/entities/transport_plan.dart';

/// Data model for TransportPlan entity
/// Represents database table structure for transport plans
class TransportPlanModel {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final String planCode;
  final String? descriptionArabic;
  final String? descriptionEnglish;
  final List<String> tripTypes;
  final double monthlyPrice;
  final double setupFee;
  final List<String>? features;
  final int maxDistanceKm;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportPlanModel({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.planCode,
    this.descriptionArabic,
    this.descriptionEnglish,
    required this.tripTypes,
    required this.monthlyPrice,
    this.setupFee = 0.0,
    this.features,
    this.maxDistanceKm = 50,
    required this.isActive,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (from Supabase/PostgreSQL)
  factory TransportPlanModel.fromJson(Map<String, dynamic> json) {
    return TransportPlanModel(
      id: json['id'] as String,
      nameArabic: json['name_arabic'] as String,
      nameEnglish: json['name_english'] as String,
      planCode: json['plan_code'] as String,
      descriptionArabic: json['description_arabic'] as String?,
      descriptionEnglish: json['description_english'] as String?,
      tripTypes: List<String>.from(json['trip_types'] as List),
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      setupFee: (json['setup_fee'] as num?)?.toDouble() ?? 0.0,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : null,
      maxDistanceKm: json['max_distance_km'] as int? ?? 50,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON (for Supabase/PostgreSQL)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
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

  /// Convert to domain entity
  TransportPlan toEntity() {
    return TransportPlan(
      planId: id,
      planNameArabic: nameArabic,
      planNameEnglish: nameEnglish,
      planCode: planCode,
      descriptionArabic: descriptionArabic,
      descriptionEnglish: descriptionEnglish,
      tripTypes: tripTypes,
      monthlyPrice: monthlyPrice,
      setupFee: setupFee,
      features: features,
      maxDistanceKm: maxDistanceKm,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }

  /// Create from domain entity
  factory TransportPlanModel.fromEntity(TransportPlan entity) {
    final now = DateTime.now();
    return TransportPlanModel(
      id: entity.planId,
      nameArabic: entity.planNameArabic,
      nameEnglish: entity.planNameEnglish,
      planCode: entity.planCode,
      descriptionArabic: entity.descriptionArabic,
      descriptionEnglish: entity.descriptionEnglish,
      tripTypes: entity.tripTypes,
      monthlyPrice: entity.monthlyPrice,
      setupFee: entity.setupFee,
      features: entity.features,
      maxDistanceKm: entity.maxDistanceKm,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransportPlanModel &&
        other.id == id &&
        other.nameArabic == nameArabic &&
        other.nameEnglish == nameEnglish &&
        other.planCode == planCode &&
        other.descriptionArabic == descriptionArabic &&
        other.descriptionEnglish == descriptionEnglish &&
        other.monthlyPrice == monthlyPrice &&
        other.setupFee == setupFee &&
        other.maxDistanceKm == maxDistanceKm &&
        other.isActive == isActive &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nameArabic,
      nameEnglish,
      planCode,
      descriptionArabic,
      descriptionEnglish,
      monthlyPrice,
      setupFee,
      features,
      maxDistanceKm,
      isActive,
      sortOrder,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransportPlanModel(id: $id, nameArabic: $nameArabic, nameEnglish: $nameEnglish, planCode: $planCode, descriptionArabic: $descriptionArabic, descriptionEnglish: $descriptionEnglish, tripTypes: $tripTypes, monthlyPrice: $monthlyPrice, setupFee: $setupFee, features: $features, maxDistanceKm: $maxDistanceKm, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
