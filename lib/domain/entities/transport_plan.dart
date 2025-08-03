// lib/domain/entities/transport_plan.dart

/// Transport Plan domain entity
class TransportPlan {
  final String planId;
  final String planNameArabic;
  final String planNameEnglish;
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

  const TransportPlan({
    required this.planId,
    required this.planNameArabic,
    required this.planNameEnglish,
    required this.planCode,
    this.descriptionArabic,
    this.descriptionEnglish,
    required this.tripTypes,
    required this.monthlyPrice,
    this.setupFee = 0.0,
    this.features,
    this.maxDistanceKm = 50,
    this.isActive = true,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportPlan &&
          runtimeType == other.runtimeType &&
          planId == other.planId;

  @override
  int get hashCode => planId.hashCode;

  @override
  String toString() =>
      'TransportPlan(planId: $planId, planNameArabic: $planNameArabic)';
}
