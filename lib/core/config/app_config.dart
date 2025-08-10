class AppConfig {
  // روابط تحميل التطبيقات
  static const String androidAPKUrl = 'https://github.com/Adrek190/bb/releases/download/v1.0.0/msarat-app.apk';
  static const String iosAppStoreUrl = 'https://apps.apple.com/app/msarat/id123456789'; // عندما يكون متوفراً
  
  // معلومات الإصدار
  static const String currentVersion = '1.0.0';
  static const String appName = 'مسارات - النقل المدرسي';
  
  // روابط التواصل
  static const String supportEmail = 'support@msarat.app';
  static const String websiteUrl = 'https://msarat.app';
  
  // أحجام الملفات (بالميجابايت)
  static const double androidAPKSizeMB = 22.0;
  
  // رسائل التحميل
  static const String androidDownloadMessage = 'تم بدء تحميل التطبيق لنظام Android (حجم الملف: ${androidAPKSizeMB}MB)';
  static const String iosComingSoonMessage = 'تطبيق iOS قادم قريباً على App Store!';
  
  // رسالة في حالة عدم توفر الرابط
  static const String downloadNotAvailableMessage = 'رابط التحميل غير متوفر حالياً. يرجى المحاولة لاحقاً أو التواصل مع الدعم الفني.';
}
