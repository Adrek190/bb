// lib/domain/repositories/bills_repository.dart
import '../entities/bill.dart';
import '../entities/batch_bill.dart';
import '../entities/bank.dart';
import '../entities/bills_statistics.dart';

/// مستودع الفواتير - واجهة التعامل مع بيانات الفواتير
abstract class BillsRepository {
  /// الحصول على جميع الفواتير للطالب
  Future<List<Bill>> getBillsForParent(String parentId);

  /// الحصول على فاتورة محددة
  Future<Bill?> getBillById(String billId);

  /// إنشاء فاتورة جديدة
  Future<Bill> createBill(Bill bill);

  /// تحديث فاتورة
  Future<Bill> updateBill(Bill bill);

  /// حذف فاتورة
  Future<bool> deleteBill(String billId);

  /// دفع فاتورة فردية
  Future<Bill> payIndividualBill({
    required String billId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  });

  /// الحصول على جميع الفواتير المُجمعة
  Future<List<BatchBill>> getBatchBills(String parentId);

  /// الحصول على فاتورة مُجمعة محددة
  Future<BatchBill?> getBatchBillById(String batchBillId);

  /// إنشاء فاتورة مُجمعة جديدة
  Future<BatchBill> createBatchBill(BatchBill batchBill);

  /// إضافة فواتير إلى فاتورة مُجمعة
  Future<BatchBill> addBillsToBatch({
    required String batchBillId,
    required List<String> billIds,
  });

  /// إزالة فواتير من فاتورة مُجمعة
  Future<BatchBill> removeBillsFromBatch({
    required String batchBillId,
    required List<String> billIds,
  });

  /// دفع فاتورة مُجمعة
  Future<BatchBill> payBatchBill({
    required String batchBillId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  });

  /// الحصول على البنوك المتاحة
  Future<List<Bank>> getAvailableBanks();

  /// الحصول على إحصائيات الفواتير
  Future<BillsStatistics> getBillsStatistics(String parentId);

  /// البحث في الفواتير
  Future<List<Bill>> searchBills({
    required String parentId,
    String? query,
    List<BillStatus>? statuses,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// فلترة الفواتير
  Future<List<Bill>> filterBills({
    required String parentId,
    BillStatus? status,
    String? childName,
    DateTime? fromDate,
    DateTime? toDate,
  });
}
