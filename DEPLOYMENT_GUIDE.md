# دليل نشر تطبيق نقل الطلاب

## نسخة الويب (جاهزة للنشر)

تم إنشاء نسخة الويب بنجاح في المجلد: `build/web`

### رفع التطبيق على الإنترنت:

#### 1. GitHub Pages:
```bash
# إنشاء repository جديد على GitHub
# رفع محتويات مجلد build/web
# تفعيل GitHub Pages من إعدادات المستودع
```

#### 2. Netlify:
- اذهب إلى netlify.com
- اسحب مجلد `build/web` إلى الموقع
- سيتم نشر التطبيق تلقائياً

#### 3. Firebase Hosting:
```bash
npm install -g firebase-tools
firebase init hosting
# اختر مجلد build/web كمجلد public
firebase deploy
```

### تشغيل التطبيق محلياً:
```bash
cd build/web
python -m http.server 8000
# افتح http://localhost:8000 في المتصفح
```

## إنشاء APK للأندرويد

### المتطلبات:
1. تثبيت Android Studio Command Line Tools
2. قبول تراخيص Android SDK
3. تحديث Java SDK

### خطوات الحل:

#### 1. تحديث Android SDK:
- افتح Android Studio
- اذهب إلى Tools > SDK Manager
- في تبويب SDK Tools، فعّل:
  - Android SDK Command-line Tools (latest)
  - Android SDK Build-Tools
  - Android SDK Platform-Tools

#### 2. قبول التراخيص:
```bash
flutter doctor --android-licenses
# اضغط 'y' لكل ترخيص
```

#### 3. بناء APK:
```bash
# APK للتصحيح (أسرع)
flutter build apk --debug

# APK للإنتاج (محسن)
flutter build apk --release

# APK لجميع الهندسات المعمارية
flutter build apk --split-per-abi
```

### مواقع الملفات:
- APK Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- APK Release: `build/app/outputs/flutter-apk/app-release.apk`

## استكشاف الأخطاء:

### إذا فشل بناء APK:
1. تأكد من تثبيت Java 11 أو أحدث
2. تحديث متغيرات البيئة:
   ```bash
   set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
   set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
   ```
3. تنظيف المشروع:
   ```bash
   flutter clean
   flutter pub get
   ```

### بدائل أخرى:
- تصدير لـ Windows: `flutter build windows`
- تصدير للويب: `flutter build web`
- تطبيق ويب تقدمي (PWA): إضافة service worker

## معلومات التطبيق:
- الاسم: Student Transport App
- النسخة: 1.0.0+1
- المنصات المدعومة: Android, Web, Windows
- معرف التطبيق: com.example.student_transport_app
