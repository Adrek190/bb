// lib/domain/entities/batch_bill.dart

/// كيان الفاتورة المُجمعة
class BatchBill {
  final String batchBillId;
  final String parentId;
  final String batchNumber;
  final String batchDescription;
  final double totalAmount;
  final int individualBillsCount;
  final double paidAmount;
  final String? bankId;
  final String? bankName;
  final String? transferNumber;
  final String? receiptImagePath;
  final DateTime? paymentDate;
  final BatchBillStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNotes;
  final String? paymentNotes;
  final bool isActive;

  const BatchBill({
    required this.batchBillId,
    required this.parentId,
    required this.batchNumber,
    required this.batchDescription,
    required this.totalAmount,
    required this.individualBillsCount,
    this.paidAmount = 0.0,
    this.bankId,
    this.bankName,
    this.transferNumber,
    this.receiptImagePath,
    this.paymentDate,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.adminNotes,
    this.paymentNotes,
    this.isActive = true,
  });

  /// نسخ الكيان مع تحديث بعض الخصائص
  BatchBill copyWith({
    String? batchBillId,
    String? parentId,
    String? batchNumber,
    String? batchDescription,
    double? totalAmount,
    int? individualBillsCount,
    double? paidAmount,
    String? bankId,
    String? bankName,
    String? transferNumber,
    String? receiptImagePath,
    DateTime? paymentDate,
    BatchBillStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
    String? paymentNotes,
    bool? isActive,
  }) {
    return BatchBill(
      batchBillId: batchBillId ?? this.batchBillId,
      parentId: parentId ?? this.parentId,
      batchNumber: batchNumber ?? this.batchNumber,
      batchDescription: batchDescription ?? this.batchDescription,
      totalAmount: totalAmount ?? this.totalAmount,
      individualBillsCount: individualBillsCount ?? this.individualBillsCount,
      paidAmount: paidAmount ?? this.paidAmount,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      transferNumber: transferNumber ?? this.transferNumber,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      paymentNotes: paymentNotes ?? this.paymentNotes,
      isActive: isActive ?? this.isActive,
    );
  }

  /// التحقق من إمكانية الدفع
  bool get canBePaid => status == BatchBillStatus.pending && isActive;

  /// حساب المبلغ المتبقي
  double get remainingAmount => totalAmount - paidAmount;

  /// التحقق من انتهاء موعد الاستحقاق
  bool get isOverdue {
    if (dueDate == null || status != BatchBillStatus.pending) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// نسبة المبلغ المدفوع
  double get paymentPercentage {
    if (totalAmount == 0) return 0.0;
    return (paidAmount / totalAmount) * 100;
  }

  /// الحصول على نص حالة الفاتورة
  String get statusText {
    switch (status) {
      case BatchBillStatus.pending:
        return isOverdue ? 'متأخرة' : 'معلقة';
      case BatchBillStatus.paid:
        return 'مدفوعة';
      case BatchBillStatus.cancelled:
        return 'ملغاة';
      case BatchBillStatus.partiallyPaid:
        return 'مدفوعة جزئياً';
    }
  }

  @override
  String toString() {
    return 'BatchBill(batchBillId: $batchBillId, batchNumber: $batchNumber, totalAmount: $totalAmount, status: $status)';
  }
}

/// حالات الفاتورة المُجمعة
enum BatchBillStatus { pending, paid, cancelled, partiallyPaid }

/// تحويل النص إلى enum
extension BatchBillStatusExtension on BatchBillStatus {
  String get name {
    switch (this) {
      case BatchBillStatus.pending:
        return 'pending';
      case BatchBillStatus.paid:
        return 'paid';
      case BatchBillStatus.cancelled:
        return 'cancelled';
      case BatchBillStatus.partiallyPaid:
        return 'partially_paid';
    }
  }

  static BatchBillStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BatchBillStatus.pending;
      case 'paid':
        return BatchBillStatus.paid;
      case 'cancelled':
        return BatchBillStatus.cancelled;
      case 'partially_paid':
        return BatchBillStatus.partiallyPaid;
      default:
        return BatchBillStatus.pending;
    }
  }
}
