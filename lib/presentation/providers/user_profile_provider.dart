import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UserProfileProvider extends ChangeNotifier {
  // بيانات المستخدم
  String _userName = 'Abu Bakr Khaled-1-72';
  String _userEmail = 'aboobk.algmae@gmail.com';
  String _userAddress = 'العنوان';
  String _userPhone = '0565108900';
  XFile? _profileImage;

  // مفاتيح التخزين المحلي
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userAddressKey = 'user_address';
  static const String _userPhoneKey = 'user_phone';
  static const String _profileImageKey = 'profile_image_path';

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAddress => _userAddress;
  String get userPhone => _userPhone;
  XFile? get profileImage => _profileImage;

  // تحديد ما إذا كان لدى المستخدم صورة شخصية
  bool get hasProfileImage => _profileImage != null;

  // تهيئة البيانات من التخزين المحلي
  Future<void> initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _userName = prefs.getString(_userNameKey) ?? 'Abu Bakr Khaled-1-72';
    _userEmail = prefs.getString(_userEmailKey) ?? 'aboobk.algmae@gmail.com';
    _userAddress = prefs.getString(_userAddressKey) ?? 'العنوان';
    _userPhone = prefs.getString(_userPhoneKey) ?? '0565108900';

    // استرجاع مسار الصورة
    final imagePath = prefs.getString(_profileImageKey);
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        // للويب، نحتاج للتحقق من صحة المسار
        if (kIsWeb || File(imagePath).existsSync()) {
          _profileImage = XFile(imagePath);
        }
      } catch (e) {
        // إذا كانت الصورة غير صالحة، احذفها من التخزين
        await prefs.remove(_profileImageKey);
      }
    }

    notifyListeners();
  }

  // تحديث الاسم
  Future<void> updateUserName(String name) async {
    if (name.trim().isEmpty) return;

    _userName = name.trim();
    notifyListeners();

    // حفظ في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
  }

  // تحديث البريد الإلكتروني
  Future<void> updateUserEmail(String email) async {
    if (email.trim().isEmpty) return;

    _userEmail = email.trim();
    notifyListeners();

    // حفظ في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, _userEmail);
  }

  // تحديث العنوان
  Future<void> updateUserAddress(String address) async {
    if (address.trim().isEmpty) return;

    _userAddress = address.trim();
    notifyListeners();

    // حفظ في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAddressKey, _userAddress);
  }

  // تحديث رقم الهاتف
  Future<void> updateUserPhone(String phone) async {
    if (phone.trim().isEmpty) return;

    _userPhone = phone.trim();
    notifyListeners();

    // حفظ في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, _userPhone);
  }

  // تحديث الصورة الشخصية
  Future<void> updateProfileImage(XFile? image) async {
    _profileImage = image;
    notifyListeners();

    // حفظ مسار الصورة في التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    if (image != null) {
      await prefs.setString(_profileImageKey, image.path);
    } else {
      await prefs.remove(_profileImageKey);
    }
  }

  // الحصول على الصورة كـ ImageProvider للاستخدام في الواجهات
  ImageProvider? getProfileImageProvider() {
    if (_profileImage == null) return null;

    if (kIsWeb) {
      return NetworkImage(_profileImage!.path);
    } else {
      return FileImage(File(_profileImage!.path));
    }
  }

  // بناء CircleAvatar للمستخدم مع التحديث التلقائي
  Widget buildUserAvatar({
    double radius = 20.0,
    Color backgroundColor = Colors.amber,
    Color iconColor = Colors.grey,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: getProfileImageProvider(),
        child: _profileImage == null
            ? Icon(Icons.person, color: iconColor, size: radius * 0.8)
            : null,
      ),
    );
  }

  // مسح جميع بيانات المستخدم (عند تسجيل الخروج)
  Future<void> clearUserData() async {
    _userName = 'Abu Bakr Khaled-1-72';
    _userEmail = 'aboobk.algmae@gmail.com';
    _userAddress = 'العنوان';
    _userPhone = '0565108900';
    _profileImage = null;

    notifyListeners();

    // مسح التخزين المحلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userAddressKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_profileImageKey);
  }

  // تحديث متعدد البيانات (لتحسين الأداء)
  Future<void> updateMultipleFields({
    String? name,
    String? email,
    String? address,
    String? phone,
    XFile? image,
  }) async {
    bool hasChanges = false;
    final prefs = await SharedPreferences.getInstance();

    if (name != null && name.trim().isNotEmpty && name.trim() != _userName) {
      _userName = name.trim();
      await prefs.setString(_userNameKey, _userName);
      hasChanges = true;
    }

    if (email != null &&
        email.trim().isNotEmpty &&
        email.trim() != _userEmail) {
      _userEmail = email.trim();
      await prefs.setString(_userEmailKey, _userEmail);
      hasChanges = true;
    }

    if (address != null &&
        address.trim().isNotEmpty &&
        address.trim() != _userAddress) {
      _userAddress = address.trim();
      await prefs.setString(_userAddressKey, _userAddress);
      hasChanges = true;
    }

    if (phone != null &&
        phone.trim().isNotEmpty &&
        phone.trim() != _userPhone) {
      _userPhone = phone.trim();
      await prefs.setString(_userPhoneKey, _userPhone);
      hasChanges = true;
    }

    if (image != _profileImage) {
      _profileImage = image;
      if (image != null) {
        await prefs.setString(_profileImageKey, image.path);
      } else {
        await prefs.remove(_profileImageKey);
      }
      hasChanges = true;
    }

    // إشعار المستمعين فقط إذا كان هناك تغييرات
    if (hasChanges) {
      notifyListeners();
    }
  }
}
