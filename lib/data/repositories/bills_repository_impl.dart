// lib/data/repositories/bills_repository_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/batch_bill.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/bills_statistics.dart';
import '../../domain/repositories/bills_repository.dart';
import '../models/bill_model.dart';
import '../models/batch_bill_model.dart';
import '../models/bank_model.dart';

/// تنفيذ مستودع الفواتير
class BillsRepositoryImpl implements BillsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Bill>> getBillsForParent(String parentId) async {
    try {
      print('📡 استدعاء دالة جلب الفواتير للوالد: $parentId');

      final response = await _supabase.rpc(
        'get_all_user_bills',
        params: {'input_parent_id': parentId},
      );

      print('📋 استجابة قاعدة البيانات: ${response?.length ?? 0} عنصر');

      if (response == null) {
        print('⚠️ الاستجابة فارغة من قاعدة البيانات');
        return [];
      }

      final bills = (response as List)
          .map((billData) => BillModel.fromJson(billData).toEntity())
          .toList();

      print('✅ تم تحويل ${bills.length} فاتورة بنجاح');
      return bills;
    } catch (e) {
      print('❌ خطأ في جلب الفواتير: $e');
      throw Exception('خطأ في جلب الفواتير: $e');
    }
  }

  @override
  Future<Bill?> getBillById(String billId) async {
    try {
      final response = await _supabase
          .from('bills')
          .select('*')
          .eq('bill_id', billId)
          .maybeSingle();

      if (response == null) return null;

      return BillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في جلب الفاتورة: $e');
    }
  }

  @override
  Future<Bill> createBill(Bill bill) async {
    try {
      final response = await _supabase.rpc(
        'create_bill_safely',
        params: {
          'p_parent_id': bill.parentId,
          'p_child_name': bill.childName,
          'p_description': bill.billDescription,
          'p_amount': bill.amount,
          'p_due_date': bill.dueDate?.toIso8601String(),
          'p_admin_notes': bill.adminNotes,
        },
      );

      if (response == null) {
        throw Exception('فشل في إنشاء الفاتورة');
      }

      return BillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في إنشاء الفاتورة: $e');
    }
  }

  @override
  Future<Bill> updateBill(Bill bill) async {
    try {
      final billModel = BillModel.fromEntity(bill);
      final response = await _supabase
          .from('bills')
          .update(billModel.toJson())
          .eq('bill_id', bill.billId)
          .select()
          .single();

      return BillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في تحديث الفاتورة: $e');
    }
  }

  @override
  Future<bool> deleteBill(String billId) async {
    try {
      await _supabase
          .from('bills')
          .update({'is_active': false})
          .eq('bill_id', billId);

      return true;
    } catch (e) {
      throw Exception('خطأ في حذف الفاتورة: $e');
    }
  }

  @override
  Future<Bill> payIndividualBill({
    required String billId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  }) async {
    try {
      final response = await _supabase.rpc(
        'pay_individual_bill_with_review',
        params: {
          'p_bill_id': billId,
          'p_parent_id': _supabase.auth.currentUser?.id,
          'p_bank_id': bankId,
          'p_transfer_number': transferNumber,
          'p_receipt_image_path': receiptImagePath,
          'p_payment_notes': paymentNotes,
        },
      );

      if (response == null) {
        throw Exception('فشل في دفع الفاتورة');
      }

      return BillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في دفع الفاتورة: $e');
    }
  }

  @override
  Future<List<BatchBill>> getBatchBills(String parentId) async {
    try {
      final response = await _supabase.rpc(
        'get_payable_batch_bills',
        params: {'p_parent_id': parentId},
      );

      return (response as List)
          .map((batchData) => BatchBillModel.fromJson(batchData).toEntity())
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب الفواتير المُجمعة: $e');
    }
  }

  @override
  Future<BatchBill?> getBatchBillById(String batchBillId) async {
    try {
      final response = await _supabase
          .from('batch_bills')
          .select('*')
          .eq('batch_bill_id', batchBillId)
          .maybeSingle();

      if (response == null) return null;

      return BatchBillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في جلب الفاتورة المُجمعة: $e');
    }
  }

  @override
  Future<BatchBill> createBatchBill(BatchBill batchBill) async {
    try {
      final response = await _supabase.rpc(
        'create_batch_bill_safely',
        params: {
          'p_parent_id': batchBill.parentId,
          'p_batch_description': batchBill.batchDescription,
          'p_due_date': batchBill.dueDate?.toIso8601String(),
          'p_admin_notes': batchBill.adminNotes,
        },
      );

      if (response == null) {
        throw Exception('فشل في إنشاء الفاتورة المُجمعة');
      }

      return BatchBillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في إنشاء الفاتورة المُجمعة: $e');
    }
  }

  @override
  Future<BatchBill> addBillsToBatch({
    required String batchBillId,
    required List<String> billIds,
  }) async {
    try {
      final response = await _supabase.rpc(
        'add_bills_to_batch',
        params: {'p_batch_bill_id': batchBillId, 'p_bill_ids': billIds},
      );

      if (response == null) {
        throw Exception('فشل في إضافة الفواتير للمجموعة');
      }

      return BatchBillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في إضافة الفواتير للمجموعة: $e');
    }
  }

  @override
  Future<BatchBill> removeBillsFromBatch({
    required String batchBillId,
    required List<String> billIds,
  }) async {
    try {
      final response = await _supabase.rpc(
        'remove_bills_from_batch',
        params: {'p_batch_bill_id': batchBillId, 'p_bill_ids': billIds},
      );

      if (response == null) {
        throw Exception('فشل في إزالة الفواتير من المجموعة');
      }

      return BatchBillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في إزالة الفواتير من المجموعة: $e');
    }
  }

  @override
  Future<BatchBill> payBatchBill({
    required String batchBillId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  }) async {
    try {
      final response = await _supabase.rpc(
        'pay_batch_bill_with_review',
        params: {
          'p_batch_bill_id': batchBillId,
          'p_parent_id': _supabase.auth.currentUser?.id,
          'p_bank_id': bankId,
          'p_transfer_number': transferNumber,
          'p_receipt_image_path': receiptImagePath,
          'p_payment_notes': paymentNotes,
        },
      );

      if (response == null) {
        throw Exception('فشل في دفع الفاتورة المُجمعة');
      }

      return BatchBillModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('خطأ في دفع الفاتورة المُجمعة: $e');
    }
  }

  @override
  Future<List<Bank>> getAvailableBanks() async {
    try {
      final response = await _supabase
          .from('banks')
          .select('*')
          .eq('is_active', true)
          .order('bank_name', ascending: true);

      return (response as List)
          .map((bankData) => BankModel.fromJson(bankData).toEntity())
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب البنوك: $e');
    }
  }

  @override
  Future<BillsStatistics> getBillsStatistics(String parentId) async {
    try {
      final response = await _supabase.rpc(
        'get_bills_statistics',
        params: {'p_parent_id': parentId},
      );

      if (response == null) {
        throw Exception('فشل في جلب الإحصائيات');
      }

      return BillsStatistics(
        totalBills: response['total_bills'] ?? 0,
        pendingBills: response['pending_bills'] ?? 0,
        paidBills: response['paid_bills'] ?? 0,
        overdueBills: response['overdue_bills'] ?? 0,
        cancelledBills: response['cancelled_bills'] ?? 0,
        totalAmount: double.parse(response['total_amount']?.toString() ?? '0'),
        totalPaidAmount: double.parse(
          response['paid_amount']?.toString() ?? '0',
        ),
        pendingAmount: double.parse(
          response['pending_amount']?.toString() ?? '0',
        ),
        overdueAmount: double.parse(
          response['overdue_amount']?.toString() ?? '0',
        ),
      );
    } catch (e) {
      throw Exception('خطأ في جلب الإحصائيات: $e');
    }
  }

  @override
  Future<List<Bill>> searchBills({
    required String parentId,
    String? query,
    List<BillStatus>? statuses,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('bills')
          .select('*')
          .eq('parent_id', parentId)
          .eq('is_active', true);

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'child_name.ilike.%$query%,description.ilike.%$query%',
        );
      }

      if (statuses != null && statuses.isNotEmpty) {
        final statusStrings = statuses.map((s) => s.name).toList();
        queryBuilder = queryBuilder.inFilter('status', statusStrings);
      }

      if (fromDate != null) {
        queryBuilder = queryBuilder.gte(
          'created_at',
          fromDate.toIso8601String(),
        );
      }

      if (toDate != null) {
        queryBuilder = queryBuilder.lte('created_at', toDate.toIso8601String());
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      return (response as List)
          .map((billData) => BillModel.fromJson(billData).toEntity())
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث في الفواتير: $e');
    }
  }

  @override
  Future<List<Bill>> filterBills({
    required String parentId,
    BillStatus? status,
    String? childName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('bills')
          .select('*')
          .eq('parent_id', parentId)
          .eq('is_active', true);

      if (status != null) {
        queryBuilder = queryBuilder.eq('status', status.name);
      }

      if (childName != null && childName.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('child_name', '%$childName%');
      }

      if (fromDate != null) {
        queryBuilder = queryBuilder.gte(
          'created_at',
          fromDate.toIso8601String(),
        );
      }

      if (toDate != null) {
        queryBuilder = queryBuilder.lte('created_at', toDate.toIso8601String());
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      return (response as List)
          .map((billData) => BillModel.fromJson(billData).toEntity())
          .toList();
    } catch (e) {
      throw Exception('خطأ في فلترة الفواتير: $e');
    }
  }
}
