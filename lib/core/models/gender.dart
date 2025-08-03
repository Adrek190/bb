/// نموذج الجنس
enum Gender {
  male, // ذكر
  female, // أنثى
}

extension GenderExtension on Gender {
  /// النص العربي للعرض
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  /// المفتاح للحفظ في قاعدة البيانات
  String get key {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }

  /// أيقونة الجنس
  String get icon {
    switch (this) {
      case Gender.male:
        return '👦';
      case Gender.female:
        return '👧';
    }
  }

  /// إنشاء من مفتاح
  static Gender fromKey(String key) {
    switch (key.toLowerCase()) {
      case 'female':
        return Gender.female;
      case 'male':
      default:
        return Gender.male;
    }
  }

  /// إنشاء من النص العربي
  static Gender fromDisplayName(String displayName) {
    switch (displayName) {
      case 'أنثى':
        return Gender.female;
      case 'ذكر':
      default:
        return Gender.male;
    }
  }
}

/// مُساعد للحصول على قائمة الخيارات للواجهة
class GenderHelper {
  static List<Map<String, dynamic>> getOptions() {
    return [
      {
        'value': Gender.male,
        'key': Gender.male.key,
        'name': Gender.male.displayName,
        'icon': Gender.male.icon,
      },
      {
        'value': Gender.female,
        'key': Gender.female.key,
        'name': Gender.female.displayName,
        'icon': Gender.female.icon,
      },
    ];
  }

  static Gender? fromString(String? genderString) {
    if (genderString == null) return null;

    // جرب المفتاح أولاً
    try {
      return GenderExtension.fromKey(genderString);
    } catch (e) {
      // جرب النص العربي
      try {
        return GenderExtension.fromDisplayName(genderString);
      } catch (e) {
        return null;
      }
    }
  }
}
