import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية
  static const Color primary = Color(0xFFFFC107); // أصفر
  static const Color secondary = Color(0xFF26C6DA); // سماوي
  static const Color background = Color(0xFFFAFAFA); // خلفية فاتحة
  static const Color surface = Color(0xFFFFFFFF); // أبيض

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF2D3748); // رمادي داكن
  static const Color textSecondary = Color(0xFF718096); // رمادي متوسط
  static const Color textHint = Color(0xFFA0AEC0); // رمادي فاتح

  // ألوان الحالة
  static const Color success = Color(0xFF48BB78); // أخضر
  static const Color error = Color(0xFFF56565); // أحمر
  static const Color warning = Color(0xFFED8936); // برتقالي
  static const Color info = Color(0xFF4299E1); // أزرق

  // ألوان المراحل
  static const Color stepActive = secondary; // المرحلة النشطة
  static const Color stepCompleted = secondary; // المرحلة المكتملة
  static const Color stepInactive = Color(0xFFE2E8F0); // المرحلة غير النشطة

  // ألوان الحدود
  static const Color borderPrimary = Color(0xFFE2E8F0);
  static const Color borderSecondary = Color(0xFFCBD5E0);

  // ألوان أخرى
  static const Color divider = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x0D000000);

  // ألوان الجنس
  static const Color maleColor = Color(0xFF4299E1); // أزرق للذكور
  static const Color femaleColor = Color(0xFFED64A6); // وردي للإناث

  // ألوان الإشعارات
  static const Color notificationInfo = info; // أزرق للمعلومات
  static const Color notificationSuccess = success; // أخضر للنجاح
  static const Color notificationWarning = warning; // برتقالي للتحذير
  static const Color notificationError = error; // أحمر للخطأ
  static const Color notificationDefault = Color(0xFF718096); // رمادي افتراضي

  // ألوان خلفيات الإشعارات
  static const Color notificationUnreadBackground = Color(
    0xFFF0F8FF,
  ); // خلفية زرقاء فاتحة للإشعارات غير المقروءة
  static const Color notificationReadBackground =
      surface; // خلفية بيضاء للإشعارات المقروءة

  // ألوان حدود الإشعارات
  static const Color notificationUnreadBorder = Color(
    0xFFB3D9FF,
  ); // حدود زرقاء للإشعارات غير المقروءة
  static const Color notificationReadBorder =
      borderPrimary; // حدود رمادية للإشعارات المقروءة
}
