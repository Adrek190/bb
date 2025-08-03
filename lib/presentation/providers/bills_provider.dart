// lib/presentation/providers/bills_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/bill.dart';
import '../../domain/entities/batch_bill.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/bills_statistics.dart';
import '../../domain/repositories/bills_repository.dart';
import '../../core/services/auth_service.dart';

/// مقدم حالة الفواتير
class BillsProvider with ChangeNotifier {
  final BillsRepository _billsRepository;
  final AuthService _authService;

  BillsProvider({
    required BillsRepository billsRepository,
    required AuthService authService,
  }) : _billsRepository = billsRepository,
       _authService = authService;

  // حالة الفواتير الفردية
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;

  // حالة الفواتير المُجمعة
  List<BatchBill> _batchBills = [];
  List<BatchBill> get batchBills => _batchBills;

  // حالة البنوك
  List<Bank> _banks = [];
  List<Bank> get banks => _banks;

  // الإحصائيات
  BillsStatistics? _statistics;
  BillsStatistics? get statistics => _statistics;

  // حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // حالة الخطأ
  String? _error;
  String? get error => _error;

  // الفواتير المحددة للدفع المُجمع
  final List<Bill> _selectedBills = [];
  List<Bill> get selectedBills => _selectedBills;

  // الفاتورة المحددة حاليًا
  Bill? _selectedBill;
  Bill? get selectedBill => _selectedBill;

  // البنك المحدد للدفع
  Bank? _selectedBank;
  Bank? get selectedBank => _selectedBank;

  /// تحديد فاتورة
  void selectBill(Bill bill) {
    _selectedBill = bill;
    notifyListeners();
  }

  /// إزالة تحديد الفاتورة
  void clearSelectedBill() {
    _selectedBill = null;
    notifyListeners();
  }

  /// تحديد بنك للدفع
  void selectBank(Bank bank) {
    _selectedBank = bank;
    notifyListeners();
  }

  /// إزالة تحديد البنك
  void clearSelectedBank() {
    _selectedBank = null;
    notifyListeners();
  }

  /// إضافة فاتورة للتحديد للدفع المُجمع
  void selectBillForBatch(Bill bill) {
    if (!_selectedBills.contains(bill) && bill.status == BillStatus.pending) {
      _selectedBills.add(bill);
      notifyListeners();
    }
  }

  /// إزالة فاتورة من التحديد للدفع المُجمع
  void unselectBillForBatch(Bill bill) {
    _selectedBills.remove(bill);
    notifyListeners();
  }

  /// تبديل تحديد فاتورة للدفع المُجمع
  void toggleBillSelection(Bill bill) {
    if (_selectedBills.contains(bill)) {
      unselectBillForBatch(bill);
    } else {
      selectBillForBatch(bill);
    }
  }

  /// مسح جميع الفواتير المحددة
  void clearSelectedBills() {
    _selectedBills.clear();
    notifyListeners();
  }

  /// حساب المبلغ الإجمالي للفواتير المحددة
  double get selectedBillsTotal {
    return _selectedBills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  /// جلب جميع البيانات للمستخدم الحالي
  Future<void> loadAllData() async {
    try {
      print('🔄 بدء تحميل بيانات الفواتير...');
      _setLoading(true);
      _clearError();

      // الحصول على معرف الوالد من AuthService
      final parentId = await _authService.getParentId();
      print('👤 معرف الوالد المحصل عليه: $parentId');

      if (parentId == null) {
        print('❌ لم يتم العثور على معرف الوالد');
        throw Exception('لم يتم العثور على معرف الوالد');
      }

      print('📝 بدء تحميل الفواتير للوالد: $parentId');

      // تحميل جميع البيانات
      await Future.wait([
        loadBills(parentId),
        loadBatchBills(parentId),
        loadBanks(),
        loadStatistics(parentId),
      ]);

      print(
        '✅ تم تحميل ${_bills.length} فاتورة فردية و ${_batchBills.length} فاتورة مجمعة',
      );
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
      _setError('خطأ في تحميل البيانات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// جلب جميع الفواتير للوالد
  Future<void> loadBills(String parentId) async {
    await _performAsyncOperation(() async {
      print('🔍 استدعاء getBillsForParent للوالد: $parentId');
      _bills = await _billsRepository.getBillsForParent(parentId);
      print('📊 تم جلب ${_bills.length} فاتورة');
    });
  }

  /// جلب الفواتير المُجمعة
  Future<void> loadBatchBills(String parentId) async {
    await _performAsyncOperation(() async {
      _batchBills = await _billsRepository.getBatchBills(parentId);
    });
  }

  /// جلب البنوك المتاحة
  Future<void> loadBanks() async {
    await _performAsyncOperation(() async {
      _banks = await _billsRepository.getAvailableBanks();
    });
  }

  /// جلب الإحصائيات
  Future<void> loadStatistics(String parentId) async {
    await _performAsyncOperation(() async {
      _statistics = await _billsRepository.getBillsStatistics(parentId);
    });
  }

  /// دفع فاتورة فردية
  Future<bool> payIndividualBill({
    required String billId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  }) async {
    try {
      _setLoading(true);

      final updatedBill = await _billsRepository.payIndividualBill(
        billId: billId,
        bankId: bankId,
        transferNumber: transferNumber,
        receiptImagePath: receiptImagePath,
        paymentNotes: paymentNotes,
      );

      // تحديث الفاتورة في القائمة
      final index = _bills.indexWhere((bill) => bill.billId == billId);
      if (index != -1) {
        _bills[index] = updatedBill;
      }

      _selectedBill = updatedBill;
      _clearError();
      return true;
    } catch (e) {
      _setError('خطأ في دفع الفاتورة: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إنشاء وإدارة فاتورة مُجمعة
  Future<BatchBill?> createBatchBill({
    required String parentId,
    required String description,
    DateTime? dueDate,
    String? adminNotes,
  }) async {
    try {
      _setLoading(true);

      // إنشاء الفاتورة المُجمعة
      final batchBill = BatchBill(
        batchBillId: '', // سيتم توليده من قاعدة البيانات
        parentId: parentId,
        batchNumber: '', // سيتم توليده من قاعدة البيانات
        batchDescription: description,
        totalAmount: selectedBillsTotal,
        individualBillsCount: _selectedBills.length,
        status: BatchBillStatus.pending,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        adminNotes: adminNotes,
      );

      final createdBatch = await _billsRepository.createBatchBill(batchBill);

      // إضافة الفواتير للمجموعة
      if (_selectedBills.isNotEmpty) {
        final billIds = _selectedBills.map((bill) => bill.billId).toList();
        await _billsRepository.addBillsToBatch(
          batchBillId: createdBatch.batchBillId,
          billIds: billIds,
        );
      }

      // تحديث القوائم
      _batchBills.insert(0, createdBatch);
      clearSelectedBills();

      _clearError();
      return createdBatch;
    } catch (e) {
      _setError('خطأ في إنشاء الفاتورة المُجمعة: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// دفع فاتورة مُجمعة
  Future<bool> payBatchBill({
    required String batchBillId,
    required String bankId,
    required String transferNumber,
    String? receiptImagePath,
    String? paymentNotes,
  }) async {
    try {
      _setLoading(true);

      final updatedBatch = await _billsRepository.payBatchBill(
        batchBillId: batchBillId,
        bankId: bankId,
        transferNumber: transferNumber,
        receiptImagePath: receiptImagePath,
        paymentNotes: paymentNotes,
      );

      // تحديث الفاتورة المُجمعة في القائمة
      final index = _batchBills.indexWhere(
        (batch) => batch.batchBillId == batchBillId,
      );
      if (index != -1) {
        _batchBills[index] = updatedBatch;
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('خطأ في دفع الفاتورة المُجمعة: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// البحث في الفواتير
  Future<List<Bill>> searchBills({
    required String parentId,
    String? query,
    List<BillStatus>? statuses,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _billsRepository.searchBills(
        parentId: parentId,
        query: query,
        statuses: statuses,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _setError('خطأ في البحث: $e');
      return [];
    }
  }

  /// فلترة الفواتير
  Future<List<Bill>> filterBills({
    required String parentId,
    BillStatus? status,
    String? childName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _billsRepository.filterBills(
        parentId: parentId,
        status: status,
        childName: childName,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      _setError('خطأ في الفلترة: $e');
      return [];
    }
  }

  /// تحديث جميع البيانات
  Future<void> refreshAll(String parentId) async {
    await Future.wait([
      loadBills(parentId),
      loadBatchBills(parentId),
      loadBanks(),
      loadStatistics(parentId),
    ]);
  }

  /// تنفيذ عملية غير متزامنة مع إدارة الحالة
  Future<void> _performAsyncOperation(Future<void> Function() operation) async {
    try {
      _setLoading(true);
      await operation();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تعيين رسالة خطأ
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// إعادة تعيين جميع الحالات
  void reset() {
    _bills.clear();
    _batchBills.clear();
    _banks.clear();
    _statistics = null;
    _selectedBills.clear();
    _selectedBill = null;
    _selectedBank = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
