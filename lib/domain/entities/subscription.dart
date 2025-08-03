/// أنواع الاشتراك
enum SubscriptionType {
  monthly, // شهري
  term, // ترم
  yearly, // سنوي
}

/// حالات الاشتراك
enum SubscriptionStatus {
  active, // نشط
  inactive, // غير نشط
  suspended, // معلق
  expired, // منتهي
  cancelled, // ملغى
}

/// كيان الاشتراك
class SubscriptionEntity {
  final String subscriptionId;
  final String parentId;
  final String? childId;
  final String relatedRequestId;
  final String? relatedBillId;
  final SubscriptionType subscriptionType;
  final SubscriptionStatus subscriptionStatus;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? activatedAt;
  final DateTime? suspendedAt;
  final DateTime? cancelledAt;
  final double subscriptionAmount;
  final double paidAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? adminNotes;
  final bool autoRenewal;

  const SubscriptionEntity({
    required this.subscriptionId,
    required this.parentId,
    this.childId,
    required this.relatedRequestId,
    this.relatedBillId,
    required this.subscriptionType,
    required this.subscriptionStatus,
    required this.startDate,
    required this.endDate,
    this.activatedAt,
    this.suspendedAt,
    this.cancelledAt,
    required this.subscriptionAmount,
    required this.paidAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.adminNotes,
    required this.autoRenewal,
  });

  /// نسخ مع تحديث
  SubscriptionEntity copyWith({
    String? subscriptionId,
    String? parentId,
    String? childId,
    String? relatedRequestId,
    String? relatedBillId,
    SubscriptionType? subscriptionType,
    SubscriptionStatus? subscriptionStatus,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? activatedAt,
    DateTime? suspendedAt,
    DateTime? cancelledAt,
    double? subscriptionAmount,
    double? paidAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? adminNotes,
    bool? autoRenewal,
  }) {
    return SubscriptionEntity(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
      relatedBillId: relatedBillId ?? this.relatedBillId,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      activatedAt: activatedAt ?? this.activatedAt,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      adminNotes: adminNotes ?? this.adminNotes,
      autoRenewal: autoRenewal ?? this.autoRenewal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionEntity &&
        other.subscriptionId == subscriptionId &&
        other.parentId == parentId &&
        other.childId == childId &&
        other.relatedRequestId == relatedRequestId &&
        other.relatedBillId == relatedBillId &&
        other.subscriptionType == subscriptionType &&
        other.subscriptionStatus == subscriptionStatus &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.subscriptionAmount == subscriptionAmount &&
        other.paidAmount == paidAmount &&
        other.isActive == isActive &&
        other.autoRenewal == autoRenewal;
  }

  @override
  int get hashCode {
    return Object.hash(
      subscriptionId,
      parentId,
      childId,
      relatedRequestId,
      relatedBillId,
      subscriptionType,
      subscriptionStatus,
      startDate,
      endDate,
      subscriptionAmount,
      paidAmount,
      isActive,
      autoRenewal,
    );
  }

  @override
  String toString() {
    return 'SubscriptionEntity(subscriptionId: $subscriptionId, parentId: $parentId, childId: $childId, subscriptionType: $subscriptionType, subscriptionStatus: $subscriptionStatus, startDate: $startDate, endDate: $endDate)';
  }
}
