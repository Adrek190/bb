@echo off
REM إعداد متغيرات البيئة المحلية لمشروع Flutter Android مع التحقق

echo ========================================
echo Flutter Android - Local Environment Setup
========================================

REM تعيين متغيرات البيئة
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot
set GRADLE_HOME=C:\gradle-8.13
set ANDROID_HOME=C:\Users\H\AppData\Local\Android\Sdk
set PATH=%JAVA_HOME%\bin;%GRADLE_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%

echo [1/3] JAVA_HOME: %JAVA_HOME%
echo [2/3] GRADLE_HOME: %GRADLE_HOME%
echo [3/3] ANDROID_HOME: %ANDROID_HOME%

echo.
echo ========================================
echo التحقق من الأدوات المحلية
========================================

echo Java (Local JDK):
java -version 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Java not found! Check JAVA_HOME: %JAVA_HOME%
) else (
    echo ✅ Java found locally
)

echo.
echo Gradle (Local Installation):
gradle -version 2>nul  
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Gradle not found! Check GRADLE_HOME: %GRADLE_HOME%
) else (
    echo ✅ Gradle found locally
)

echo.
echo Android SDK (Local):
if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    echo ✅ Android SDK found locally
) else (
    echo ❌ Android SDK not found! Check ANDROID_HOME: %ANDROID_HOME%
)

echo.
echo ========================================
echo البيئة المحلية جاهزة!
echo ========================================
echo 🚀 استخدم gradle_local.bat أو gradle مباشرة

echo أوامر مهمة:
echo   gradle_local.bat assembleRelease

echo.
pause
