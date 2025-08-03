@echo off
echo ========================================
echo Flutter Android - Local Environment Setup
echo No Internet Downloads - Using Local Tools Only
echo ========================================

REM تعيين متغيرات البيئة للبيئة المحلية فقط
REM Setting environment variables for local environment only

echo [1/3] Setting ANDROID_HOME (Local SDK)...
set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\sdk

echo [2/3] Setting GRADLE_HOME (Local Gradle 8.13)...
set GRADLE_HOME=C:\gradle-8.13

echo [3/3] Setting JAVA_HOME (Local JDK)...
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot

echo.
echo [4/4] Adding to PATH...
set PATH=%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%GRADLE_HOME%\bin;%JAVA_HOME%\bin;%PATH%

echo.
echo ========================================
echo Environment Variables (Local Only):
echo ========================================
echo ANDROID_HOME: %ANDROID_HOME%
echo GRADLE_HOME: %GRADLE_HOME%  
echo JAVA_HOME: %JAVA_HOME%
echo.

echo ========================================
echo Verifying Local Tools...
echo ========================================

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
echo Local Environment Ready!
echo ========================================
echo 🚀 Use gradle_local.bat instead of gradlew
echo 📦 No internet downloads required
echo 🔧 Using only local tools
echo.
echo Commands:
echo   gradle_local.bat assembleRelease
echo   gradle_local.bat clean
echo.
pause
