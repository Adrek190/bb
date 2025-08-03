# دليل بناء المشروع باستخدام متغيرات البيئة
# Android Build Guide using Environment Variables

## ✅ التغييرات المطبقة | Applied Changes

تم تعديل المشروع ليستخدم متغيرات البيئة التالية:
- **ANDROID_HOME** - للاتصال بـ Android SDK
- **GRADLE_HOME** - لاستخدام Gradle العام بدلاً من التحميل التلقائي  
- **JAVA_HOME** - لاستخدام JDK المحدد

## 📋 المتطلبات | Requirements

### 1. تثبيت المكونات الأساسية
- **Android SDK** (Android Studio أو command line tools)
- **Gradle 8.4+** (تثبيت منفصل)
- **JDK 17+**

### 2. تعيين متغيرات البيئة في النظام

#### Windows (PowerShell/CMD):
```powershell
# ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\$env:USERNAME\AppData\Local\Android\sdk", "User")

# GRADLE_HOME  
[Environment]::SetEnvironmentVariable("GRADLE_HOME", "C:\gradle\gradle-8.4", "User")

# JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")
```

## 🚀 طريقة التشغيل | How to Run

### الطريقة السريعة | Quick Method
```bash
# 1. تعيين متغيرات البيئة للجلسة الحالية
cd android
setup_env.bat

# 2. بناء المشروع
gradlew_custom.bat build

# 3. تشغيل التطبيق
cd ..
flutter run
```

## 📁 الملفات المعدلة | Modified Files

### ✅ تم حذف الملفات القديمة:
- `android/gradlew` (القديم)
- `android/gradlew.bat` (القديم)

### ✅ الملفات الجديدة/المعدلة:
- `android/local.properties` - يستخدم `${ANDROID_HOME}`
- `android/gradle.properties` - يستخدم `${JAVA_HOME}`  
- `android/gradle/wrapper/gradle-wrapper.properties` - تم تعطيل التحميل التلقائي
- `android/gradlew_custom.bat` - ملف gradle مخصص يستخدم `GRADLE_HOME`
- `android/gradlew_custom` - نسخة Linux/Mac
- `android/setup_env.bat` - ملف لتعيين متغيرات البيئة
- `android/.gitignore` - محدث ليشمل الملفات الجديدة

## 🔧 الأوامر المفيدة | Useful Commands

```bash
# تنظيف المشروع
android\gradlew_custom.bat clean

# بناء APK للإطلاق
android\gradlew_custom.bat assembleRelease

# بناء Bundle
android\gradlew_custom.bat bundleRelease

# عرض المهام المتاحة
android\gradlew_custom.bat tasks
```

## ⚠️ ملاحظات مهمة | Important Notes

1. **تأكد من تثبيت المكونات:** Android SDK, Gradle, JDK في المسارات المحددة
2. **استخدم الملفات الجديدة:** `gradlew_custom.bat` بدلاً من `gradlew.bat` 
3. **تعديل المسارات:** قم بتعديل المسارات في `setup_env.bat` حسب نظامك
4. **إعادة تشغيل Terminal:** بعد تعيين متغيرات البيئة في النظام

## 🐛 حل المشاكل | Troubleshooting

### مشكلة: "GRADLE_HOME is not set"
```bash
# تأكد من تشغيل setup_env.bat أولاً
android\setup_env.bat
```

### مشكلة: "Java not found"  
```bash
# تحقق من تثبيت JDK وتعيين JAVA_HOME
java -version
echo %JAVA_HOME%
```

### مشكلة: "Android SDK not found"
```bash
# تحقق من تثبيت Android SDK وتعيين ANDROID_HOME
echo %ANDROID_HOME%
dir "%ANDROID_HOME%\platform-tools"
```
