// lib/domain/entities/bill.dart

/// كيان الفاتورة الفردية
class Bill {
  final String billId;
  final String parentId;
  final String? relatedRequestId;
  final String billNumber;
  final String billDescription;
  final double amount;
  final double paidAmount;
  final String? bankId;
  final String? bankName;
  final String? transferNumber;
  final String? receiptImagePath;
  final BillStatus status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNotes;
  final String? paymentNotes;
  final bool isActive;

  // معلومات إضافية من الـ JOIN
  final String? childName;
  final String? schoolName;
  final String? cityName;
  final String? districtName;

  const Bill({
    required this.billId,
    required this.parentId,
    this.relatedRequestId,
    required this.billNumber,
    required this.billDescription,
    required this.amount,
    this.paidAmount = 0.0,
    this.bankId,
    this.bankName,
    this.transferNumber,
    this.receiptImagePath,
    required this.status,
    this.dueDate,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.adminNotes,
    this.paymentNotes,
    this.isActive = true,
    this.childName,
    this.schoolName,
    this.cityName,
    this.districtName,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  Bill copyWith({
    String? billId,
    String? parentId,
    String? relatedRequestId,
    String? billNumber,
    String? billDescription,
    double? amount,
    double? paidAmount,
    String? bankId,
    String? bankName,
    String? transferNumber,
    String? receiptImagePath,
    BillStatus? status,
    DateTime? dueDate,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
    String? paymentNotes,
    bool? isActive,
    String? childName,
    String? schoolName,
    String? cityName,
    String? districtName,
  }) {
    return Bill(
      billId: billId ?? this.billId,
      parentId: parentId ?? this.parentId,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
      billNumber: billNumber ?? this.billNumber,
      billDescription: billDescription ?? this.billDescription,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      transferNumber: transferNumber ?? this.transferNumber,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      paymentNotes: paymentNotes ?? this.paymentNotes,
      isActive: isActive ?? this.isActive,
      childName: childName ?? this.childName,
      schoolName: schoolName ?? this.schoolName,
      cityName: cityName ?? this.cityName,
      districtName: districtName ?? this.districtName,
    );
  }

  /// التحقق من إمكانية الدفع
  bool get canBePaid => status == BillStatus.pending && isActive;

  /// التحقق من إمكانية الاختيار للدفع المُجمع
  bool get canBeSelectedForBatch => canBePaid;

  /// حساب المبلغ المتبقي
  double get remainingAmount => amount - paidAmount;

  /// التحقق من انتهاء موعد الاستحقاق
  bool get isOverdue {
    if (dueDate == null || status != BillStatus.pending) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// الحصول على نص حالة الفاتورة
  String get statusText {
    switch (status) {
      case BillStatus.pending:
        return isOverdue ? 'متأخرة' : 'معلقة';
      case BillStatus.underReview:
        return 'تحت المراجعة';
      case BillStatus.paid:
        return 'مدفوعة';
      case BillStatus.cancelled:
        return 'ملغاة';
      case BillStatus.overdue:
        return 'متأخرة';
      case BillStatus.partiallyPaid:
        return 'مدفوعة جزئياً';
      case BillStatus.rejected:
        return 'مرفوضة';
    }
  }

  @override
  String toString() {
    return 'Bill(billId: $billId, billNumber: $billNumber, amount: $amount, status: $status)';
  }
}

/// حالات الفاتورة
enum BillStatus {
  pending, // معلقة - في انتظار الدفع
  underReview, // تحت المراجعة - تم الدفع وفي انتظار التأكيد
  paid, // مدفوعة - تم التأكيد من المدير
  cancelled, // ملغاة
  overdue, // متأخرة
  partiallyPaid, // مدفوعة جزئياً
  rejected, // مرفوضة - تم رفض الدفع من المدير
}

/// تحويل النص إلى enum
extension BillStatusExtension on BillStatus {
  String get name {
    switch (this) {
      case BillStatus.pending:
        return 'pending';
      case BillStatus.underReview:
        return 'under_review';
      case BillStatus.paid:
        return 'paid';
      case BillStatus.cancelled:
        return 'cancelled';
      case BillStatus.overdue:
        return 'overdue';
      case BillStatus.partiallyPaid:
        return 'partially_paid';
      case BillStatus.rejected:
        return 'rejected';
    }
  }

  static BillStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BillStatus.pending;
      case 'under_review':
        return BillStatus.underReview;
      case 'paid':
        return BillStatus.paid;
      case 'cancelled':
        return BillStatus.cancelled;
      case 'overdue':
        return BillStatus.overdue;
      case 'partially_paid':
        return BillStatus.partiallyPaid;
      case 'rejected':
        return BillStatus.rejected;
      default:
        return BillStatus.pending;
    }
  }
}
