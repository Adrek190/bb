# دليل استخدام القائمة السفلية

## نظرة عامة
تم إنشاء وتحديث `MainNavigationPage` لتشمل قائمة تنقل سفلية تحتوي على 4 صفحات رئيسية:

## الصفحات المتضمنة

### 1. 🏠 الصفحة الرئيسية (Home Page)
- **الملف**: `lib/presentation/pages/home_page.dart`
- **الوصف**: صفحة البداية التي تعرض ملخص للمستخدم
- **الرمز**: `Icons.home`

### 2. 👶 إضافة ابن (Add Child)
- **الملف**: `lib/presentation/pages/children/add_child_wizard_page.dart`
- **الوصف**: صفحة إضافة طفل جديد بنظام الخطوات
- **الرمز**: `Icons.person_add`

### 3. 🔔 الإشعارات (Notifications)
- **الملف**: `lib/presentation/pages/notifications_page.dart`
- **الوصف**: صفحة عرض الإشعارات مع التحديث المباشر
- **الرمز**: `Icons.notifications`

### 4. 👤 الملف الشخصي (Profile)
- **الملف**: `lib/presentation/pages/profile_page.dart`
- **الوصف**: صفحة بيانات المستخدم الشخصية
- **الرمز**: `Icons.person`

## المميزات

### ✨ التصميم والألوان
- استخدام `AppColors` للألوان الموحدة
- ألوان متدرجة للعناصر المحددة وغير المحددة
- ظلال وحدود لتحسين المظهر
- دعم الرموز النشطة وغير النشطة

### 🔄 التفاعل والحركة
- انتقالات سلسة بين الصفحات
- `FadeTransition` للانتقال بين المحتوى
- `AnimationController` لتحكم أفضل بالحركة
- مدة انتقال 300 مللي ثانية

### 🎨 تحسينات المظهر
- إزالة `elevation` الافتراضي
- إضافة `boxShadow` مخصص
- خلفية شفافة للتنقل السفلي
- خطوط مختلفة للنص المحدد وغير المحدد

## كيفية الاستخدام

### في main.dart
```dart
// التطبيق يتوجه تلقائياً إلى MainNavigationPage بعد تسجيل الدخول
home: Consumer<AuthService>(
  builder: (context, authService, child) {
    if (authService.isSignedIn) {
      return const MainNavigationPage(); // ✅ القائمة السفلية
    }
    return const LoginPage();
  },
),
```

### في الكود
```dart
// للتنقل المباشر إلى MainNavigationPage
Navigator.of(context).pushReplacementNamed('/main');

// أو
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const MainNavigationPage()),
);
```

## التحديثات المطبقة

### ✅ التغييرات الأساسية
1. **استبدال الصفحات**:
   - ❌ إزالة: `RequestsPage`, `BillsPage`
   - ✅ إضافة: `AddChildWizardPage`, `ProfilePage`

2. **تحديث العناوين**:
   - الرئيسية، إضافة ابن، الإشعارات، الملف الشخصي

3. **تحديث الرموز**:
   - رموز منطقية لكل صفحة
   - رموز نشطة ورموز غير نشطة مختلفة

### 🎨 التحسينات البصرية
1. **الألوان**:
   - `selectedItemColor`: `AppColors.primary` (أصفر)
   - `unselectedItemColor`: `AppColors.textHint` (رمادي فاتح)

2. **الخطوط**:
   - النص المحدد: `fontSize: 12, fontWeight: FontWeight.w600`
   - النص غير المحدد: `fontSize: 11, fontWeight: FontWeight.normal`

3. **الظلال والحدود**:
   - ظل علوي للتنقل السفلي
   - خلفية شفافة مع container مخصص

### 🔄 التفاعل والحركة
1. **AnimationController**:
   - مدة 300 مللي ثانية
   - منحنى `Curves.easeInOut`

2. **FadeTransition**:
   - انتقال سلس بين الصفحات
   - إعادة تشغيل الانيميشن عند التبديل

## ملاحظات التطوير

### 🚨 مشاكل تم حلها
1. **AppDrawer**: تم إزالته لعدم الحاجة إليه مع التنقل السفلي
2. **withOpacity**: تم استبداله بـ `withValues(alpha: 0.1)` لتجنب التحذيرات
3. **Unused imports**: تم تنظيف الاستيرادات غير المستخدمة

### 📱 التوافق
- ✅ Flutter الحديث
- ✅ Material Design 3
- ✅ دعم اللغة العربية (RTL)
- ✅ أجهزة مختلفة الأحجام

## الملفات المرتبطة

```
lib/
├── presentation/
│   ├── pages/
│   │   ├── main_navigation_page.dart     # 🎯 الملف الرئيسي
│   │   ├── home_page.dart               # صفحة الرئيسية
│   │   ├── notifications_page.dart      # صفحة الإشعارات  
│   │   ├── profile_page.dart           # صفحة الملف الشخصي
│   │   └── children/
│   │       └── add_child_wizard_page.dart # صفحة إضافة طفل
│   └── widgets/
│       └── custom_app_bar.dart         # شريط التطبيق المخصص
└── core/
    └── themes/
        └── app_colors.dart             # ألوان التطبيق
```

تم إنجاز المهمة بنجاح! 🎉
