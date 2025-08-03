import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/transport_plan.dart';

class TransportPlanProvider extends ChangeNotifier {
  // البيانات
  final List<TransportPlan> _transportPlans = [];
  String? _selectedTransportPlanId;
  List<String> _selectedTripTypes = [];
  String _subscriptionType = 'شهري';

  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TransportPlan> get transportPlans => _transportPlans;
  String? get selectedTransportPlanId => _selectedTransportPlanId;
  List<String> get selectedTripTypes => _selectedTripTypes;
  String get subscriptionType => _subscriptionType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // التحقق من اكتمال البيانات
  bool get isSelectionComplete {
    return _selectedTripTypes.isNotEmpty && _subscriptionType.isNotEmpty;
  }

  // تحديث الاختيارات
  void updateTransportPlan(String planId) {
    _selectedTransportPlanId = planId;
    debugPrint('تم تحديث خطة النقل: $planId');
    notifyListeners();
  }

  void updateTripTypes(List<String> tripTypes) {
    _selectedTripTypes = tripTypes;
    debugPrint('تم تحديث أنواع الرحلات: $tripTypes');
    notifyListeners();
  }

  void updateSubscriptionType(String subscriptionType) {
    _subscriptionType = subscriptionType;
    debugPrint('تم تحديث نوع الاشتراك: $subscriptionType');
    notifyListeners();
  }

  // تحميل خطط النقل من قاعدة البيانات
  Future<void> loadTransportPlans() async {
    _setLoading(true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('transport_plans')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      debugPrint('📡 Response from transport_plans: $response');
      debugPrint('📡 Response type: ${response.runtimeType}');

      if (response.isNotEmpty) {
        _transportPlans.clear();

        for (final item in response) {
          debugPrint('📦 Processing item: $item');
          debugPrint('📦 Item type: ${item.runtimeType}');

          try {
            final plan = TransportPlan.fromJson(item);
            if (plan.planNameArabic.isNotEmpty) {
              _transportPlans.add(plan);
              debugPrint(
                '✅ Added plan: ${plan.planNameArabic} - ID: ${plan.planId}',
              );
            }
          } catch (planError) {
            debugPrint('❌ Error parsing plan: $planError');
            debugPrint('❌ Item data: $item');
          }
        }

        if (_transportPlans.isNotEmpty) {
          debugPrint(
            '✅ تم تحميل ${_transportPlans.length} خطة نقل من قاعدة البيانات',
          );

          // طباعة تفاصيل الخطط المحملة
          for (final plan in _transportPlans) {
            debugPrint('📋 خطة: ${plan.planNameArabic} - ID: ${plan.planId}');
          }
        } else {
          debugPrint('⚠️ لم يتم تحميل أي خطط صحيحة من قاعدة البيانات');
          _createLocalTransportPlans();
        }
      } else {
        debugPrint('⚠️ لم يتم العثور على خطط نقل في قاعدة البيانات');
        _createLocalTransportPlans();
      }
      _clearError();
    } catch (e) {
      debugPrint('❌ خطأ في تحميل خطط النقل: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      _setError('فشل في تحميل خطط النقل: ${e.toString()}');
      // في حالة الخطأ، استخدم خطط محلية مؤقتة
      _createLocalTransportPlans();
    } finally {
      _setLoading(false);
    }
  }

  // إنشاء خطط النقل المحلية باستخدام IDs من قاعدة البيانات
  void _createLocalTransportPlans() {
    debugPrint('⚠️ استخدام خطط محلية مع IDs من قاعدة البيانات');

    _transportPlans.clear();

    // استخدام IDs الفعلية من قاعدة البيانات
    _transportPlans.addAll([
      TransportPlan(
        planId: '57a53e29-4e01-4875-a78b-d6fb8706cb32', // ID من قاعدة البيانات
        planNameArabic: 'ذهاب فقط',
        planNameEnglish: 'One Way',
        planCode: 'ONE_WAY',
        descriptionArabic: 'نقل الطلاب من المنزل إلى المدرسة',
        tripTypes: {'to_school': true},
        monthlyPrice: 200.0,
        setupFee: 50.0,
        maxDistanceKm: 30,
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransportPlan(
        planId: '7bb56ea9-8d4b-4057-8b67-1cd085815901', // ID من قاعدة البيانات
        planNameArabic: 'إياب فقط',
        planNameEnglish: 'Return Only',
        planCode: 'RETURN_ONLY',
        descriptionArabic: 'نقل الطلاب من المدرسة إلى المنزل',
        tripTypes: {'from_school': true},
        monthlyPrice: 200.0,
        setupFee: 50.0,
        maxDistanceKm: 30,
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransportPlan(
        planId: 'de89934e-e095-4949-ba47-fe3613482e9a', // ID من قاعدة البيانات
        planNameArabic: 'ذهاب وإياب',
        planNameEnglish: 'Round Trip',
        planCode: 'ROUND_TRIP',
        descriptionArabic: 'نقل الطلاب ذهاباً وإياباً',
        tripTypes: {'to_school': true, 'from_school': true},
        monthlyPrice: 350.0,
        setupFee: 50.0,
        maxDistanceKm: 30,
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    debugPrint(
      '✅ تم إنشاء ${_transportPlans.length} خطة نقل بـ IDs صحيحة من قاعدة البيانات',
    );

    // طباعة الخطط للتأكد
    for (final plan in _transportPlans) {
      debugPrint('📋 ${plan.planNameArabic}: ${plan.planId}');
    }
  }

  // التحقق من صحة الاختيار

  bool validateSelection() {
    final isValid = isSelectionComplete;

    debugPrint('_validatePlanSelection: $isValid');
    debugPrint('transportPlanId: $_selectedTransportPlanId');
    debugPrint('tripTypes: $_selectedTripTypes');
    debugPrint('subscriptionType: $_subscriptionType');

    return isValid;
  }

  // البحث عن خطة نقل بالمعرف
  TransportPlan? getTransportPlanById(String planId) {
    try {
      return _transportPlans.firstWhere((plan) => plan.planId == planId);
    } catch (e) {
      return null;
    }
  }

  // البحث عن خطة نقل بالاسم العربي
  TransportPlan? getTransportPlanByArabicName(String arabicName) {
    try {
      return _transportPlans.firstWhere(
        (plan) => plan.planNameArabic == arabicName,
      );
    } catch (e) {
      return null;
    }
  }

  // الحصول على plan_id من اسم الخطة العربية
  String? getPlanIdFromArabicName(String arabicName) {
    final plan = getTransportPlanByArabicName(arabicName);
    return plan?.planId;
  }

  // الحصول على السعر الإجمالي
  double getTotalPrice() {
    final plan = getTransportPlanById(_selectedTransportPlanId ?? '');
    if (plan == null) return 0.0;

    return plan.monthlyPrice + plan.setupFee;
  }

  // إعادة تعيين جميع الاختيارات
  void reset() {
    _selectedTransportPlanId = null;
    _selectedTripTypes.clear();
    _subscriptionType = 'شهري';
    _clearError();
    notifyListeners();
  }

  // إدارة حالة التحميل والأخطاء
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();

  // تحضير البيانات للإرسال
  Map<String, dynamic> getSelectionData() {
    // التحقق من صحة البيانات قبل الإرسال
    if (_selectedTripTypes.isEmpty) {
      debugPrint('❌ خطأ: لم يتم اختيار نوع رحلة');
      throw Exception('يجب اختيار نوع الرحلة');
    }

    // الحصول على plan_id الصحيح بناءً على اسم الخطة المختارة
    final selectedPlanName =
        _selectedTripTypes.first; // اسم الخطة العربية المختارة
    final planId = getPlanIdFromArabicName(selectedPlanName);

    if (planId == null) {
      debugPrint('❌ خطأ: لا يوجد plan_id لـ "$selectedPlanName"');
      debugPrint('الخطط المتاحة:');
      for (final plan in _transportPlans) {
        debugPrint('  - ${plan.planNameArabic}: ${plan.planId}');
      }
      throw Exception('الخطة المختارة غير موجودة في قاعدة البيانات');
    }

    // التحقق من وجود الخطة في قاعدة البيانات
    final selectedPlan = getTransportPlanById(planId);
    if (selectedPlan == null) {
      debugPrint('❌ خطأ: plan_id غير موجود في قاعدة البيانات: $planId');
      throw Exception('plan_id غير صحيح');
    }

    debugPrint('✅ بيانات الخطة صحيحة للإرسال:');
    debugPrint('  - اسم الخطة المختارة: $selectedPlanName');
    debugPrint('  - plan_id: ${selectedPlan.planId}');
    debugPrint('  - نوع الاشتراك: $_subscriptionType');

    return {
      'transport_plan_id':
          selectedPlan.planId, // إرسال plan_id الصحيح من قاعدة البيانات
      'subscription_type': _subscriptionType,
    };
  }
}
