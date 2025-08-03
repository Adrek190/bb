import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/parent_entity.dart';
import '../../domain/repositories/parent_repository.dart';

/// Provider for managing parent profile state and operations
///
/// This provider handles:
/// - Loading and caching parent profile data
/// - Updating parent information (name, email, phone)
/// - Managing profile image upload and updates
/// - Form validation and error handling
/// - Loading states for UI feedback
class ParentProfileProvider extends ChangeNotifier {
  final ParentRepository _parentRepository;

  ParentProfileProvider(this._parentRepository);

  // الحالة الحالية
  ParentEntity? _currentParent;
  bool _isLoading = false;
  String? _error;
  bool _isUpdating = false;
  XFile? _selectedImage;

  // Getters للحالة
  ParentEntity? get currentParent => _currentParent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUpdating => _isUpdating;
  XFile? get selectedImage => _selectedImage;

  // Getters للبيانات
  String get parentName => _currentParent?.parentName ?? '';
  String get parentEmail => _currentParent?.email ?? '';
  String get parentPhone => _currentParent?.phone ?? '';
  String? get profileImageUrl => _currentParent?.profileImageUrl;
  bool get isVerified => _currentParent?.isVerified ?? false;
  DateTime? get lastLogin => _currentParent?.lastLogin;
  DateTime? get createdAt => _currentParent?.createdAt;

  /// تحميل بيانات الوالد
  Future<void> loadParentProfile({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _setError(null);

    try {
      _currentParent = await _parentRepository.getCurrentParent();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('خطأ في تحميل بيانات الوالد: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث اسم الوالد
  Future<bool> updateParentName(String newName) async {
    if (_currentParent == null) return false;
    if (newName.trim().isEmpty) {
      _setError('الاسم لا يمكن أن يكون فارغاً');
      return false;
    }

    _setUpdating(true);
    _setError(null);

    try {
      final updatedParent = await _parentRepository.updateParentName(
        _currentParent!.parentId,
        newName,
      );

      _currentParent = updatedParent;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('خطأ في تحديث الاسم: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// تحديث بريد الوالد الإلكتروني
  Future<bool> updateParentEmail(String newEmail) async {
    if (_currentParent == null) return false;

    _setUpdating(true);
    _setError(null);

    try {
      final updatedParent = await _parentRepository.updateParentEmail(
        _currentParent!.parentId,
        newEmail,
      );

      _currentParent = updatedParent;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('خطأ في تحديث البريد الإلكتروني: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// تحديث رقم هاتف الوالد
  Future<bool> updateParentPhone(String newPhone) async {
    if (_currentParent == null) return false;
    if (newPhone.trim().isEmpty) {
      _setError('رقم الهاتف لا يمكن أن يكون فارغاً');
      return false;
    }

    _setUpdating(true);
    _setError(null);

    try {
      final updatedParent = await _parentRepository.updateParentPhone(
        _currentParent!.parentId,
        newPhone,
      );

      _currentParent = updatedParent;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('خطأ في تحديث رقم الهاتف: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// اختيار صورة جديدة
  Future<void> selectProfileImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في اختيار الصورة: $e');
      debugPrint('خطأ في اختيار الصورة: $e');
    }
  }

  /// رفع وتحديث الصورة الشخصية
  Future<bool> uploadAndUpdateProfileImage() async {
    if (_currentParent == null || _selectedImage == null) return false;

    _setUpdating(true);
    _setError(null);

    try {
      // رفع الصورة
      final imageUrl = await _parentRepository.uploadProfileImage(
        _currentParent!.parentId,
        _selectedImage!.path,
      );

      // تحديث بيانات الوالد
      final updatedParent = await _parentRepository.updateParentProfileImage(
        _currentParent!.parentId,
        imageUrl,
      );

      _currentParent = updatedParent;
      _selectedImage = null; // مسح الصورة المحددة
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('خطأ في رفع الصورة: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// إلغاء اختيار الصورة
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  /// إعادة تحميل البيانات (pull-to-refresh)
  Future<void> refresh() async {
    await loadParentProfile(forceRefresh: true);
  }

  /// مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تعيين حالة التحديث
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  /// تعيين رسالة الخطأ
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    if (email.trim().isEmpty) return true; // البريد الإلكتروني اختياري
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف
  bool isValidPhone(String phone) {
    if (phone.trim().isEmpty) return false;
    // أرقام الهاتف السعودية
    final saudiPhoneRegex = RegExp(r'^(05|5)\d{8}$|^\+9665\d{8}$');
    return saudiPhoneRegex.hasMatch(
      phone.replaceAll(' ', '').replaceAll('-', ''),
    );
  }

  /// تنسيق رقم الهاتف للعرض
  String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+966')) {
      return phone.replaceFirst('+966', '0');
    }
    return phone;
  }

  /// تنسيق تاريخ آخر دخول
  String formatLastLogin() {
    if (lastLogin == null) return 'لم يسجل دخول من قبل';

    final now = DateTime.now();
    final difference = now.difference(lastLogin!);

    if (difference.inDays > 0) {
      return 'آخر دخول منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'آخر دخول منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'آخر دخول منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'متصل الآن';
    }
  }

  /// تنسيق تاريخ الانضمام
  String formatJoinDate() {
    if (createdAt == null) return '';

    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return 'عضو منذ ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }
}
