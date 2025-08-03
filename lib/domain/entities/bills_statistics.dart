// lib/domain/entities/bills_statistics.dart

/// إحصائيات الفواتير
class BillsStatistics {
  final int totalBills;
  final int pendingBills;
  final int paidBills;
  final int overdueBills;
  final int cancelledBills;
  final double totalAmount;
  final double totalPaidAmount;
  final double pendingAmount;
  final double overdueAmount;

  const BillsStatistics({
    this.totalBills = 0,
    this.pendingBills = 0,
    this.paidBills = 0,
    this.overdueBills = 0,
    this.cancelledBills = 0,
    this.totalAmount = 0.0,
    this.totalPaidAmount = 0.0,
    this.pendingAmount = 0.0,
    this.overdueAmount = 0.0,
  });

  /// نسبة الفواتير المدفوعة
  double get paymentPercentage {
    if (totalBills == 0) return 0.0;
    return (paidBills / totalBills) * 100;
  }

  /// نسبة المبلغ المدفوع
  double get amountPaymentPercentage {
    if (totalAmount == 0) return 0.0;
    return (totalPaidAmount / totalAmount) * 100;
  }

  /// المبلغ المتبقي للدفع
  double get remainingAmount => totalAmount - totalPaidAmount;

  /// نسخ الكيان مع تحديث بعض الخصائص
  BillsStatistics copyWith({
    int? totalBills,
    int? pendingBills,
    int? paidBills,
    int? overdueBills,
    int? cancelledBills,
    double? totalAmount,
    double? totalPaidAmount,
    double? pendingAmount,
    double? overdueAmount,
  }) {
    return BillsStatistics(
      totalBills: totalBills ?? this.totalBills,
      pendingBills: pendingBills ?? this.pendingBills,
      paidBills: paidBills ?? this.paidBills,
      overdueBills: overdueBills ?? this.overdueBills,
      cancelledBills: cancelledBills ?? this.cancelledBills,
      totalAmount: totalAmount ?? this.totalAmount,
      totalPaidAmount: totalPaidAmount ?? this.totalPaidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      overdueAmount: overdueAmount ?? this.overdueAmount,
    );
  }

  @override
  String toString() {
    return 'BillsStatistics(totalBills: $totalBills, totalAmount: $totalAmount, paidAmount: $totalPaidAmount)';
  }
}
