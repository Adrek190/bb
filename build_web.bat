@echo off
echo ========================================
echo         بناء وضغط تطبيق الويب
echo ========================================

echo.
echo 1. بناء تطبيق الويب...
call flutter build web --release --dart2js-optimization O4

echo.
echo 2. التحقق من حجم المجلد...
powershell -Command "Get-ChildItem -Path 'build\web' -Recurse | Measure-Object -Property Length -Sum | Select-Object @{Name='Size(MB)';Expression={[math]::round($_.Sum/1MB,2)}}"

echo.
echo 3. ضغط ملفات الويب...
powershell -Command "Compress-Archive -Path 'build\web\*' -DestinationPath 'build\msarat-web-app.zip' -Force"

echo.
echo 4. التحقق من حجم الملف المضغوط...
powershell -Command "Get-Item 'build\msarat-web-app.zip' | Select-Object @{Name='Size(MB)';Expression={[math]::round($_.Length/1MB,2)}}"

echo.
echo ========================================
echo         تم الانتهاء!
echo ========================================
echo.
echo ملف الويب المضغوط: build\msarat-web-app.zip
echo يمكنك الآن رفعه على Netlify أو أي خدمة استضافة أخرى
echo.
pause
