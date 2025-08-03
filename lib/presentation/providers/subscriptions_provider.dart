import 'package:flutter/foundation.dart';
import '../../data/models/subscription_model.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionsProvider with ChangeNotifier {
  List<SubscriptionModel> _subscriptions = [];
  bool _isLoading = false;
  String? _error;
  String? _currentParentId;

  // Getters
  List<SubscriptionModel> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasSubscriptions => _subscriptions.isNotEmpty;

  // تصفية الاشتراكات
  List<SubscriptionModel> get activeSubscriptions => _subscriptions
      .where((s) => s.subscriptionStatus == SubscriptionStatus.active)
      .toList();

  List<SubscriptionModel> get expiredSubscriptions => _subscriptions
      .where((s) => s.subscriptionStatus == SubscriptionStatus.expired)
      .toList();

  List<SubscriptionModel> get expiringSoonSubscriptions =>
      _subscriptions.where((s) => s.isExpiringSoon).toList();

  int get totalActiveSubscriptions => activeSubscriptions.length;
  int get totalExpiredSubscriptions => expiredSubscriptions.length;
  int get totalExpiringSoonSubscriptions => expiringSoonSubscriptions.length;

  double get totalSubscriptionValue => _subscriptions.fold(
    0.0,
    (sum, subscription) => sum + subscription.subscriptionAmount,
  );

  /// تحميل اشتراكات المستخدم
  Future<void> loadUserSubscriptions(String parentId) async {
    if (_currentParentId == parentId && _subscriptions.isNotEmpty) {
      return; // البيانات محملة مسبقاً لنفس المستخدم
    }

    _setLoading(true);
    _clearError();
    _currentParentId = parentId;

    try {
      // محاكاة استدعاء API - ستحتاج لاستبدال هذا بالاستدعاء الحقيقي
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية - ستحتاج لاستبدالها بالاستدعاء الحقيقي لقاعدة البيانات
      final mockData = _generateMockSubscriptions(parentId);

      _subscriptions = mockData;
      _setLoading(false);

      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل الاشتراكات: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// تجديد قائمة الاشتراكات
  Future<void> refreshSubscriptions() async {
    if (_currentParentId != null) {
      _subscriptions.clear();
      await loadUserSubscriptions(_currentParentId!);
    }
  }

  /// إنشاء فاتورة تجديد اشتراك (بدلاً من التجديد المباشر)
  Future<Map<String, dynamic>?> createRenewalBill(
    String subscriptionId, {
    int renewalMonths = 1,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // استدعاء دالة إنشاء فاتورة التجديد في قاعدة البيانات
      // في التطبيق الحقيقي، ستحتاج لاستخدام Supabase client هنا
      await Future.delayed(const Duration(seconds: 2));

      // البحث عن الاشتراك
      final subscriptionIndex = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );

      if (subscriptionIndex == -1) {
        throw Exception('الاشتراك غير موجود');
      }

      final currentSubscription = _subscriptions[subscriptionIndex];

      // محاكاة نتيجة إنشاء فاتورة التجديد
      final renewalBillResult = {
        'success': true,
        'message': 'تم إنشاء فاتورة التجديد بنجاح',
        'bill_id': 'RENEW-${DateTime.now().millisecondsSinceEpoch}',
        'subscription_id': subscriptionId,
        'bill_number':
            'RENEW-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${subscriptionId.substring(0, 8)}',
        'amount': 750.0 * renewalMonths, // 750 ريال لكل شهر
        'due_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'renewal_months': renewalMonths,
        'child_name': currentSubscription.childName,
      };

      _setLoading(false);
      notifyListeners();

      return renewalBillResult;
    } catch (e) {
      _setError('خطأ في إنشاء فاتورة التجديد: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// تجديد اشتراك معين (دالة قديمة - محفوظة للتوافق)
  @Deprecated('استخدم createRenewalBill بدلاً من ذلك')
  Future<bool> renewSubscription(
    String subscriptionId, {
    SubscriptionType? newType,
    double? amount,
  }) async {
    // إنشاء فاتورة تجديد بدلاً من التجديد المباشر
    final result = await createRenewalBill(subscriptionId, renewalMonths: 1);
    return result != null && result['success'] == true;
  }

  /// إلغاء اشتراك
  Future<bool> cancelSubscription(String subscriptionId, String reason) async {
    _setLoading(true);
    _clearError();

    try {
      // محاكاة استدعاء API لإلغاء الاشتراك
      await Future.delayed(const Duration(seconds: 1));

      final subscriptionIndex = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );

      if (subscriptionIndex == -1) {
        throw Exception('الاشتراك غير موجود');
      }

      final cancelledSubscription = _subscriptions[subscriptionIndex].copyWith(
        subscriptionStatus: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        adminNotes: reason,
        updatedAt: DateTime.now(),
      );

      _subscriptions[subscriptionIndex] = cancelledSubscription;
      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('خطأ في إلغاء الاشتراك: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// الحصول على اشتراك بالمعرف
  SubscriptionModel? getSubscriptionById(String subscriptionId) {
    try {
      return _subscriptions.firstWhere(
        (subscription) => subscription.subscriptionId == subscriptionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// تصفية الاشتراكات حسب النوع
  List<SubscriptionModel> getSubscriptionsByType(SubscriptionType type) {
    return _subscriptions.where((s) => s.subscriptionType == type).toList();
  }

  /// تصفية الاشتراكات حسب الحالة
  List<SubscriptionModel> getSubscriptionsByStatus(SubscriptionStatus status) {
    return _subscriptions.where((s) => s.subscriptionStatus == status).toList();
  }

  /// مسح الخطأ
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// تنظيف البيانات
  @override
  void dispose() {
    _subscriptions.clear();
    _currentParentId = null;
    _clearError();
    super.dispose();
  }

  // دوال مساعدة خاصة
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
  }

  void _clearError() {
    _error = null;
  }

  /// معالجة دفع فاتورة التجديد وتحديث الاشتراك
  Future<bool> processRenewalPayment(
    String billId,
    String subscriptionId,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // استدعاء دالة معالجة دفع فاتورة التجديد في قاعدة البيانات
      // في التطبيق الحقيقي، ستحتاج لاستخدام Supabase client هنا
      await Future.delayed(const Duration(seconds: 2));

      // البحث عن الاشتراك وتحديثه
      final subscriptionIndex = _subscriptions.indexWhere(
        (s) => s.subscriptionId == subscriptionId,
      );

      if (subscriptionIndex == -1) {
        throw Exception('الاشتراك غير موجود');
      }

      final currentSubscription = _subscriptions[subscriptionIndex];

      // محاكاة تحديث الاشتراك بعد دفع فاتورة التجديد
      final updatedSubscription = currentSubscription.copyWith(
        subscriptionStatus: SubscriptionStatus.active,
        endDate: currentSubscription.endDate.add(
          const Duration(days: 30),
        ), // إضافة شهر
        updatedAt: DateTime.now(),
      );

      _subscriptions[subscriptionIndex] = updatedSubscription;
      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('خطأ في معالجة دفع التجديد: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// إنشاء فاتورة تجديد بأنواع مختلفة
  Future<Map<String, dynamic>?> createRenewalBillWithType(
    String subscriptionId,
    SubscriptionType renewalType,
  ) async {
    int renewalMonths;
    switch (renewalType) {
      case SubscriptionType.monthly:
        renewalMonths = 1;
        break;
      case SubscriptionType.term:
        renewalMonths = 6;
        break;
      case SubscriptionType.yearly:
        renewalMonths = 12;
        break;
    }

    return await createRenewalBill(
      subscriptionId,
      renewalMonths: renewalMonths,
    );
  }

  /// توليد بيانات تجريبية - ستحتاج لحذف هذه الدالة عند ربط API حقيقي
  List<SubscriptionModel> _generateMockSubscriptions(String parentId) {
    final now = DateTime.now();

    return [
      SubscriptionModel(
        subscriptionId: '1',
        parentId: parentId,
        childId: 'child1',
        relatedRequestId: 'req1',
        relatedBillId: 'bill1',
        subscriptionType: SubscriptionType.monthly,
        subscriptionStatus: SubscriptionStatus.active,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15)),
        activatedAt: now.subtract(const Duration(days: 15)),
        subscriptionAmount: 300.0,
        paidAmount: 300.0,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
        isActive: true,
        autoRenewal: true,
        childName: 'أحمد محمد',
        isRenewable: true,
        subscriptionTypeName: 'شهري',
        subscriptionStatusName: 'نشط',
      ),
      SubscriptionModel(
        subscriptionId: '2',
        parentId: parentId,
        childId: 'child2',
        relatedRequestId: 'req2',
        relatedBillId: 'bill2',
        subscriptionType: SubscriptionType.term,
        subscriptionStatus: SubscriptionStatus.active,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 120)),
        activatedAt: now.subtract(const Duration(days: 60)),
        subscriptionAmount: 1500.0,
        paidAmount: 1500.0,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 60)),
        isActive: true,
        autoRenewal: false,
        childName: 'فاطمة أحمد',
        isRenewable: true,
        subscriptionTypeName: 'ترم',
        subscriptionStatusName: 'نشط',
      ),
      SubscriptionModel(
        subscriptionId: '3',
        parentId: parentId,
        childId: 'child3',
        relatedRequestId: 'req3',
        relatedBillId: 'bill3',
        subscriptionType: SubscriptionType.monthly,
        subscriptionStatus: SubscriptionStatus.expired,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 5)),
        activatedAt: now.subtract(const Duration(days: 60)),
        subscriptionAmount: 300.0,
        paidAmount: 300.0,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
        isActive: false,
        autoRenewal: false,
        childName: 'خالد سعد',
        isRenewable: true,
        subscriptionTypeName: 'شهري',
        subscriptionStatusName: 'منتهي',
      ),
    ];
  }
}
