@echo off
REM إعداد متغيرات البيئة المحلية لمشروع Flutter Android
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot
set GRADLE_HOME=C:\gradle-8.13
set ANDROID_HOME=C:\Users\H\AppData\Local\Android\Sdk
set PATH=%JAVA_HOME%\bin;%GRADLE_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%
echo تم تعيين متغيرات البيئة بنجاح.
pause
