import '../../domain/entities/subscription.dart';

/// Model للاشتراك - للتحويل من وإلى قاعدة البيانات
class SubscriptionModel extends SubscriptionEntity {
  /// تنسيق تاريخ البداية
  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  /// تنسيق تاريخ النهاية
  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  /// حساب تقدم الاشتراك (0.0 - 1.0)
  double get subscriptionProgress {
    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsedDuration = now.difference(startDate).inDays;
    if (totalDuration <= 0) return 1.0;
    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  final String childName;
  final bool isRenewable;
  final String subscriptionTypeName;
  final String subscriptionStatusName;

  const SubscriptionModel({
    required super.subscriptionId,
    required super.parentId,
    required super.childId,
    required super.relatedRequestId,
    super.relatedBillId,
    required super.subscriptionType,
    required super.subscriptionStatus,
    required super.startDate,
    required super.endDate,
    super.activatedAt,
    super.suspendedAt,
    super.cancelledAt,
    required super.subscriptionAmount,
    required super.paidAmount,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    super.adminNotes,
    required super.autoRenewal,
    required this.childName,
    required this.isRenewable,
    required this.subscriptionTypeName,
    required this.subscriptionStatusName,
  });

  /// تحويل من JSON إلى Model
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      subscriptionId: json['subscription_id'] as String,
      parentId: json['parent_id'] as String,
      childId: json['child_id'] as String?,
      relatedRequestId: json['related_request_id'] as String,
      relatedBillId: json['related_bill_id'] as String?,
      subscriptionType: _parseSubscriptionType(
        json['subscription_type'] as String,
      ),
      subscriptionStatus: _parseSubscriptionStatus(
        json['subscription_status'] as String,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      suspendedAt: json['suspended_at'] != null
          ? DateTime.parse(json['suspended_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      subscriptionAmount: double.parse(json['subscription_amount'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      adminNotes: json['admin_notes'] as String?,
      autoRenewal: json['auto_renewal'] as bool? ?? false,
      childName: json['child_name'] as String? ?? 'غير محدد',
      isRenewable: json['is_renewable'] as bool? ?? false,
      subscriptionTypeName: _getSubscriptionTypeName(
        json['subscription_type'] as String,
      ),
      subscriptionStatusName: _getSubscriptionStatusName(
        json['subscription_status'] as String,
      ),
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'parent_id': parentId,
      'child_id': childId,
      'related_request_id': relatedRequestId,
      'related_bill_id': relatedBillId,
      'subscription_type': subscriptionType.name,
      'subscription_status': subscriptionStatus.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'suspended_at': suspendedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'subscription_amount': subscriptionAmount,
      'paid_amount': paidAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'admin_notes': adminNotes,
      'auto_renewal': autoRenewal,
      'child_name': childName,
      'is_renewable': isRenewable,
    };
  }

  /// تحويل من Entity إلى Model
  factory SubscriptionModel.fromEntity(
    SubscriptionEntity entity, {
    String childName = 'غير محدد',
    bool isRenewable = false,
  }) {
    return SubscriptionModel(
      subscriptionId: entity.subscriptionId,
      parentId: entity.parentId,
      childId: entity.childId,
      relatedRequestId: entity.relatedRequestId,
      relatedBillId: entity.relatedBillId,
      subscriptionType: entity.subscriptionType,
      subscriptionStatus: entity.subscriptionStatus,
      startDate: entity.startDate,
      endDate: entity.endDate,
      activatedAt: entity.activatedAt,
      suspendedAt: entity.suspendedAt,
      cancelledAt: entity.cancelledAt,
      subscriptionAmount: entity.subscriptionAmount,
      paidAmount: entity.paidAmount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      adminNotes: entity.adminNotes,
      autoRenewal: entity.autoRenewal,
      childName: childName,
      isRenewable: isRenewable,
      subscriptionTypeName: _getSubscriptionTypeName(
        entity.subscriptionType.name,
      ),
      subscriptionStatusName: _getSubscriptionStatusName(
        entity.subscriptionStatus.name,
      ),
    );
  }

  /// نسخ مع تحديث
  @override
  SubscriptionModel copyWith({
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
    String? childName,
    bool? isRenewable,
  }) {
    return SubscriptionModel(
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
      childName: childName ?? this.childName,
      isRenewable: isRenewable ?? this.isRenewable,
      subscriptionTypeName: subscriptionType != null
          ? _getSubscriptionTypeName(subscriptionType.name)
          : subscriptionTypeName,
      subscriptionStatusName: subscriptionStatus != null
          ? _getSubscriptionStatusName(subscriptionStatus.name)
          : subscriptionStatusName,
    );
  }

  // خصائص مساعدة
  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isExpiringSoon =>
      isActive && daysRemaining <= 7 && daysRemaining >= 0;
  bool get isExpired => daysRemaining <= 0;
  @override
  bool get isActive => subscriptionStatus == SubscriptionStatus.active;

  String get statusEmoji {
    switch (subscriptionStatus) {
      case SubscriptionStatus.active:
        return '✅';
      case SubscriptionStatus.inactive:
        return '⏸️';
      case SubscriptionStatus.suspended:
        return '⏸️';
      case SubscriptionStatus.expired:
        return '⚠️';
      case SubscriptionStatus.cancelled:
        return '❌';
    }
  }

  String get typeEmoji {
    switch (subscriptionType) {
      case SubscriptionType.monthly:
        return '📅';
      case SubscriptionType.term:
        return '📚';
      case SubscriptionType.yearly:
        return '🗓️';
    }
  }

  String get daysRemainingText {
    if (isExpired) return 'منتهي';
    if (daysRemaining == 0) return 'ينتهي اليوم';
    if (daysRemaining == 1) return 'ينتهي غداً';
    return 'باقي $daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}';
  }

  // دوال مساعدة لتحويل الأنواع
  static SubscriptionType _parseSubscriptionType(String type) {
    switch (type.toLowerCase()) {
      case 'monthly':
        return SubscriptionType.monthly;
      case 'term':
        return SubscriptionType.term;
      case 'yearly':
        return SubscriptionType.yearly;
      default:
        return SubscriptionType.monthly;
    }
  }

  static SubscriptionStatus _parseSubscriptionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'inactive':
        return SubscriptionStatus.inactive;
      case 'suspended':
        return SubscriptionStatus.suspended;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.inactive;
    }
  }

  static String _getSubscriptionTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'monthly':
        return 'شهري';
      case 'term':
        return 'ترم';
      case 'yearly':
        return 'سنوي';
      default:
        return 'غير محدد';
    }
  }

  static String _getSubscriptionStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      case 'suspended':
        return 'معلق';
      case 'expired':
        return 'منتهي';
      case 'cancelled':
        return 'ملغى';
      default:
        return 'غير محدد';
    }
  }
}
