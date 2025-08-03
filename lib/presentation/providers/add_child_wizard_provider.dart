import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/city.dart';
import '../../core/models/district.dart';
import '../../core/models/school.dart';
import '../../core/models/education_level.dart';
import '../../core/models/gender.dart';
import '../../core/models/study_day.dart';
import 'transport_plan_provider.dart';

class AddChildWizardProvider extends ChangeNotifier {
  // خطوات المعالج
  int _currentStep = 0;
  final int _totalSteps = 3;

  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;

  // بيانات الطفل (الخطوة 1)
  final ChildInfo _childInfo = ChildInfo();

  // بيانات المدرسة (الخطوة 2)
  final SchoolInfo _schoolInfo = SchoolInfo();

  // خطة النقل (الخطوة 3) - استخدام provider منفصل
  final TransportPlanProvider _transportPlanProvider = TransportPlanProvider();

  // البيانات المرجعية
  List<City> _cities = [];
  List<District> _districts = [];
  List<School> _schools = [];
  List<EducationLevel> _educationLevels = [];
  final List<StudyDay> _studyDays = [];

  // Constructor
  AddChildWizardProvider() {
    _initialize();
  }

  // تهيئة المزود
  Future<void> _initialize() async {
    await loadLookupData();
  }

  // Getters
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ChildInfo get childInfo => _childInfo;
  SchoolInfo get schoolInfo => _schoolInfo;
  TransportPlanProvider get transportPlanProvider => _transportPlanProvider;
  List<City> get cities => _cities;
  List<District> get districts => _districts;
  List<School> get schools => _schools;
  List<EducationLevel> get educationLevels => _educationLevels;
  List<StudyDay> get studyDays => _studyDays;

  // التحقق من إمكانية الانتقال
  bool get canGoNext => _canGoToNextStep();
  bool get canGoPrevious => _currentStep > 0;
  bool get isLastStep => _currentStep == _totalSteps - 1;

  // التنقل بين الخطوات
  void nextStep() {
    if (canGoNext) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (canGoPrevious) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // تحديث معلومات الطفل
  void updateChildName(String name) {
    _childInfo.name = name;
    notifyListeners();
  }

  void updateChildGender(Gender gender) {
    _childInfo.gender = gender;
    notifyListeners();
  }

  void updateChildImage(String? imagePath) {
    _childInfo.profileImagePath = imagePath;
    notifyListeners();
  }

  void updateChildImageFile(File? imageFile) {
    _childInfo.profileImageFile = imageFile;
    _childInfo.profileImagePath = imageFile?.path;
    notifyListeners();
  }

  void updateChildCurrentLocation(String location) {
    _childInfo.currentLocation = location;
    notifyListeners();
  }

  void updateChildEducationLevel(String educationLevelId) {
    _childInfo.educationLevelId = educationLevelId;
    notifyListeners();
  }

  // تحديث معلومات المدرسة
  void updateSchoolCity(String cityId) {
    _schoolInfo.cityId = cityId;
    _schoolInfo.districtId = null; // إعادة تعيين المنطقة
    _schoolInfo.schoolId = null; // إعادة تعيين المدرسة
    notifyListeners();
  }

  void updateSchoolDistrict(String districtId) {
    _schoolInfo.districtId = districtId;
    _schoolInfo.schoolId = null; // إعادة تعيين المدرسة
    notifyListeners();
  }

  void updateSchoolName(String schoolId) {
    _schoolInfo.schoolId = schoolId;
    notifyListeners();
  }

  void updateEntryTime(TimeOfDay time) {
    _schoolInfo.entryTime = time;
    notifyListeners();
  }

  void updateExitTime(TimeOfDay time) {
    _schoolInfo.exitTime = time;
    notifyListeners();
  }

  void updateStudyDays(List<String> days) {
    _schoolInfo.studyDays = days;
    notifyListeners();
  }

  // تحديث خطة النقل
  void updateTransportPlan(String planId) {
    _transportPlanProvider.updateTransportPlan(planId);
    notifyListeners();
  }

  void updateTripTypes(List<String> tripTypes) {
    _transportPlanProvider.updateTripTypes(tripTypes);
    notifyListeners();
  }

  void updateSubscriptionType(String subscriptionType) {
    _transportPlanProvider.updateSubscriptionType(subscriptionType);
    notifyListeners();
  }

  // تحميل البيانات المرجعية
  Future<void> loadLookupData() async {
    _setLoading(true);
    try {
      final supabase = Supabase.instance.client;

      // تحميل المراحل الدراسية من قاعدة البيانات
      await _loadEducationLevels(supabase);

      // تحميل المدن من قاعدة البيانات
      await _loadCities(supabase);

      // تحميل خطط النقل من خلال الـ provider المنفصل
      await _transportPlanProvider.loadTransportPlans();

      // تحميل أيام الدراسة من قاعدة البيانات
      await _loadStudyDays(supabase);

      _clearError();
    } catch (e) {
      _setError('فشل في تحميل البيانات: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // تحميل المراحل الدراسية
  Future<void> _loadEducationLevels(SupabaseClient supabase) async {
    try {
      final response = await supabase
          .from('education_levels')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      _educationLevels = (response as List)
          .map((json) => EducationLevel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('خطأ في تحميل المراحل الدراسية: $e');
      // بيانات افتراضية في حالة الخطأ
      _educationLevels = [
        EducationLevel(
          id: '1',
          name: 'الصف الأول الابتدائي',
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EducationLevel(
          id: '2',
          name: 'الصف الثاني الابتدائي',
          sortOrder: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EducationLevel(
          id: '3',
          name: 'الصف الثالث الابتدائي',
          sortOrder: 3,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    }
  }

  // تحميل المدن
  Future<void> _loadCities(SupabaseClient supabase) async {
    try {
      final response = await supabase
          .from('cities')
          .select()
          .eq('is_active', true)
          .order('city_name');

      _cities = (response as List)
          .map((json) => City.fromJson(json))
          .where(
            (city) => city.cityName.isNotEmpty,
          ) // تأكد من عدم وجود أسماء فارغة
          .toSet() // إزالة المكررات
          .toList();
    } catch (e) {
      debugPrint('خطأ في تحميل المدن: $e');
      // بيانات افتراضية في حالة الخطأ
      _cities = [
        City(
          cityId: '1',
          cityName: 'الرياض',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        City(
          cityId: '2',
          cityName: 'جدة',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        City(
          cityId: '3',
          cityName: 'الدمام',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      ];
    }
  }

  // تحميل أيام الدراسة
  Future<void> _loadStudyDays(SupabaseClient supabase) async {
    try {
      final response = await supabase
          .from('study_days')
          .select()
          .eq('is_active', true)
          .order('day_order');

      _studyDays.clear();
      _studyDays.addAll(
        (response as List).map((json) => StudyDay.fromJson(json)).toList(),
      );
    } catch (e) {
      debugPrint('خطأ في تحميل أيام الدراسة: $e');
      // بيانات افتراضية في حالة الخطأ من الـ CSV المرفق
      _studyDays.clear();
      _studyDays.addAll([
        StudyDay(
          dayId: '1af06063-ad8f-4880-a5da-8334d25140fb',
          dayNameArabic: 'الأحد',
          dayNameEnglish: 'Sunday',
          dayOrder: 1,
          isWeekend: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StudyDay(
          dayId: '61032b45-dc48-435b-a5e0-c1840c990fe6',
          dayNameArabic: 'الاثنين',
          dayNameEnglish: 'Monday',
          dayOrder: 2,
          isWeekend: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StudyDay(
          dayId: '6992d4da-a917-4f9b-8e46-471b802fd8b1',
          dayNameArabic: 'الثلاثاء',
          dayNameEnglish: 'Tuesday',
          dayOrder: 3,
          isWeekend: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StudyDay(
          dayId: 'b94281ea-5762-4612-935f-e56506ee52b8',
          dayNameArabic: 'الأربعاء',
          dayNameEnglish: 'Wednesday',
          dayOrder: 4,
          isWeekend: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StudyDay(
          dayId: 'c6e6630b-c7f2-476b-a00d-14c407a3669e',
          dayNameArabic: 'الخميس',
          dayNameEnglish: 'Thursday',
          dayOrder: 5,
          isWeekend: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
    }
  }

  // تحديث المناطق بناءً على المدينة المختارة
  Future<void> updateDistrictsForCity(String cityId) async {
    _setLoading(true);
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('districts')
          .select()
          .eq('city_id', cityId)
          .eq('is_active', true)
          .order('district_name');

      _districts = (response as List)
          .map((json) => District.fromJson(json))
          .where(
            (district) => district.districtName.isNotEmpty,
          ) // تأكد من عدم وجود أسماء فارغة
          .toSet() // إزالة المكررات
          .toList();

      // إعادة تعيين المدارس عند تغيير المدينة
      _schools = [];
      _schoolInfo.districtId = null;
      _schoolInfo.schoolId = null;

      _clearError();
    } catch (e) {
      debugPrint('خطأ في تحميل المناطق: $e');
      _setError('فشل في تحميل المناطق: ${e.toString()}');
      // بيانات افتراضية في حالة الخطأ
      _districts = [
        District(
          districtId: '1',
          districtName: 'الملز',
          cityId: cityId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        District(
          districtId: '2',
          districtName: 'العليا',
          cityId: cityId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      ];
    } finally {
      _setLoading(false);
    }
  }

  // تحديث المدارس بناءً على المنطقة المختارة
  Future<void> updateSchoolsForDistrict(String districtId) async {
    _setLoading(true);
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('schools')
          .select()
          .eq('district_id', districtId)
          .order('school_name');

      _schools = (response as List)
          .map((json) => School.fromJson(json))
          .toList();

      _clearError();
    } catch (e) {
      debugPrint('خطأ في تحميل المدارس: $e');
      _setError('فشل في تحميل المدارس: ${e.toString()}');
      // بيانات افتراضية في حالة الخطأ
      _schools = [
        School(
          schoolId: '1',
          schoolName: 'مدرسة النور الابتدائية',
          schoolType: 'government',
          educationLevelId: '1',
          districtId: districtId,
          operatingHoursStart: DateTime(1970, 1, 1, 7, 0),
          operatingHoursEnd: DateTime(1970, 1, 1, 14, 0),
          workingDays: ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday'],
          capacity: 500,
          currentStudents: 300,
          isTransportAvailable: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } finally {
      _setLoading(false);
    }
  }

  // التحقق من صحة جميع البيانات
  bool validateAllSteps() {
    final childValid = _validateChildInfo();
    final schoolValid = _validateSchoolInfo();
    final planValid = _validatePlanSelection();

    debugPrint('validateAllSteps:');
    debugPrint('  Child info valid: $childValid');
    debugPrint('  School info valid: $schoolValid');
    debugPrint('  Plan selection valid: $planValid');

    return childValid && schoolValid && planValid;
  }

  // إرسال الطلب
  Future<void> submitRequest() async {
    if (!validateAllSteps()) {
      _setError('يرجى إكمال جميع البيانات المطلوبة');
      return;
    }

    _setLoading(true);
    try {
      final supabase = Supabase.instance.client;

      // الحصول على parent_id للمستخدم الحالي
      final parentId = await _getCurrentParentId(supabase);
      if (parentId == null) {
        throw Exception('لم يتم العثور على معرف المستخدم');
      }

      // تحويل أسماء الأيام إلى UUIDs
      final studyDayIds = _convertStudyDaysToIds(_schoolInfo.studyDays);

      // التحقق من صحة transportPlanId
      if (_transportPlanProvider.selectedTransportPlanId == null ||
          !_isValidUuid(_transportPlanProvider.selectedTransportPlanId!)) {
        throw Exception(
          'معرف خطة النقل غير صحيح: ${_transportPlanProvider.selectedTransportPlanId}',
        );
      }

      debugPrint('=== تصحيح البيانات ===');
      debugPrint(
        'Child info: name=${_childInfo.name}, location=${_childInfo.currentLocation}',
      );
      debugPrint('Gender: ${_childInfo.gender?.key}');
      debugPrint('Education Level ID: ${_childInfo.educationLevelId}');
      debugPrint('School ID: ${_schoolInfo.schoolId}');
      debugPrint('District ID: ${_schoolInfo.districtId}');
      debugPrint('City ID: ${_schoolInfo.cityId}');
      debugPrint('Study Days Names: ${_schoolInfo.studyDays}');
      debugPrint('Study Days IDs: $studyDayIds');
      debugPrint(
        'Transport Plan ID: ${_transportPlanProvider.selectedTransportPlanId}',
      );

      // تحضير البيانات للإرسال
      final requestData = {
        'parent_id': parentId,
        'child_name': _childInfo.name,
        'child_location': _childInfo.currentLocation,
        'gender': _childInfo.gender?.key ?? 'male',
        'education_level_id': _childInfo.educationLevelId,
        'requested_school_id': _schoolInfo.schoolId,
        'requested_district_id': _schoolInfo.districtId,
        'requested_city_id': _schoolInfo.cityId,
        'requested_entry_time': _schoolInfo.entryTime != null
            ? '${_schoolInfo.entryTime!.hour.toString().padLeft(2, '0')}:${_schoolInfo.entryTime!.minute.toString().padLeft(2, '0')}:00'
            : '07:00:00',
        'requested_exit_time': _schoolInfo.exitTime != null
            ? '${_schoolInfo.exitTime!.hour.toString().padLeft(2, '0')}:${_schoolInfo.exitTime!.minute.toString().padLeft(2, '0')}:00'
            : '14:00:00',
        'requested_study_days': studyDayIds, // مصفوفة من UUIDs
        'requested_transport_plan_id':
            _transportPlanProvider.selectedTransportPlanId,
        'status': 'pending',
        // إضافة الحقول المطلوبة الأخرى
        'submitted_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': true,
      };

      // إضافة صورة الملف الشخصي إن وجدت
      if (_childInfo.profileImageFile != null) {
        // هنا يمكن إضافة منطق رفع الصورة لاحقاً
        // requestData['profile_image_path'] = uploadedImagePath;
      }

      debugPrint('البيانات المرسلة: $requestData');

      // إرسال الطلب إلى قاعدة البيانات
      final response = await supabase
          .from('add_child_requests')
          .insert(requestData)
          .select()
          .single();

      debugPrint('تم إرسال الطلب بنجاح: ${response['request_id']}');

      _clearError();

      // إعادة تعيين النموذج
      reset();
    } catch (e) {
      debugPrint('خطأ في إرسال الطلب: $e');
      _setError('فشل في إرسال الطلب: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // الحصول على parent_id للمستخدم الحالي
  Future<String?> _getCurrentParentId(SupabaseClient supabase) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('parents')
          .select('parent_id')
          .eq('auth_id', user.id)
          .single();

      return response['parent_id'] as String?;
    } catch (e) {
      debugPrint('خطأ في جلب parent_id: $e');
      return null;
    }
  }

  // تحويل أسماء الأيام إلى UUIDs
  List<String> _convertStudyDaysToIds(List<String> dayNames) {
    final Map<String, String> dayNameToId = {
      'الأحد': '1af06063-ad8f-4880-a5da-8334d25140fb',
      'الاثنين': '61032b45-dc48-435b-a5e0-c1840c990fe6',
      'الثلاثاء': '6992d4da-a917-4f9b-8e46-471b802fd8b1',
      'الأربعاء': 'b94281ea-5762-4612-935f-e56506ee52b8',
      'الخميس': 'c6e6630b-c7f2-476b-a00d-14c407a3669e',
      'الجمعة': '92ff342f-0749-485c-8e2e-edca5f7dafcf',
      'السبت': '328b99de-57a0-4b50-b7d7-88efe9db1d36',
    };

    return dayNames
        .map((dayName) => dayNameToId[dayName])
        .where((id) => id != null)
        .cast<String>()
        .toList();
  }

  // التحقق من صحة UUID
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // إعادة تعيين جميع البيانات
  void reset() {
    _currentStep = 0;
    _childInfo.reset();
    _schoolInfo.reset();
    _transportPlanProvider.reset();
    _clearError();
    notifyListeners();
  }

  // مساعدات خاصة
  bool _canGoToNextStep() {
    switch (_currentStep) {
      case 0:
        return _validateChildInfo();
      case 1:
        return _validateSchoolInfo();
      case 2:
        return _validatePlanSelection();
      default:
        return false;
    }
  }

  bool _validateChildInfo() {
    return _childInfo.name.isNotEmpty &&
        _childInfo.gender != null &&
        _childInfo.currentLocation.isNotEmpty &&
        _childInfo.educationLevelId != null;
  }

  bool _validateSchoolInfo() {
    return _schoolInfo.cityId != null &&
        _schoolInfo.districtId != null &&
        _schoolInfo.schoolId != null &&
        _schoolInfo.entryTime != null &&
        _schoolInfo.exitTime != null &&
        _schoolInfo.studyDays.isNotEmpty;
  }

  bool _validatePlanSelection() {
    final isValid = _transportPlanProvider.validateSelection();

    debugPrint('_validatePlanSelection: $isValid');
    debugPrint(
      'transportPlanId: ${_transportPlanProvider.selectedTransportPlanId}',
    );
    debugPrint('tripTypes: ${_transportPlanProvider.selectedTripTypes}');
    debugPrint('subscriptionType: ${_transportPlanProvider.subscriptionType}');

    return isValid;
  }

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
}

// فئة معلومات الطفل
class ChildInfo {
  String name = '';
  Gender? gender;
  String? profileImagePath;
  File? profileImageFile; // للواجهة المحلية
  String currentLocation = '';
  String? educationLevelId;

  void reset() {
    name = '';
    gender = null;
    profileImagePath = null;
    profileImageFile = null;
    currentLocation = '';
    educationLevelId = null;
  }
}

// فئة معلومات المدرسة
class SchoolInfo {
  String? cityId;
  String? districtId;
  String? schoolId;
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;
  List<String> studyDays = [];

  bool get isComplete {
    return cityId != null &&
        districtId != null &&
        schoolId != null &&
        entryTime != null &&
        exitTime != null &&
        studyDays.isNotEmpty;
  }

  void reset() {
    cityId = null;
    districtId = null;
    schoolId = null;
    entryTime = null;
    exitTime = null;
    studyDays = [];
  }
}
