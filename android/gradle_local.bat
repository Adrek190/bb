@echo off
@rem ##########################################################################
@rem
@rem  Custom Gradle launcher using GRADLE_HOME from environment
@rem  لا يحمل أي شيء من الإنترنت - يستخدم البيئة المحلية فقط
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

echo ========================================
echo Using Local Environment (No Downloads)
echo ========================================

@rem التحقق من GRADLE_HOME
if "%GRADLE_HOME%"=="" (
    echo ERROR: GRADLE_HOME environment variable is not set!
    echo Please run setup_env.bat first to set environment variables.
    echo Expected: GRADLE_HOME=C:\gradle-8.13
    exit /b 1
)

@rem التحقق من JAVA_HOME
if "%JAVA_HOME%"=="" (
    echo ERROR: JAVA_HOME environment variable is not set!
    echo Please run setup_env.bat first to set environment variables.
    echo Expected: JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot
    exit /b 1
)

@rem التحقق من ANDROID_HOME
if "%ANDROID_HOME%"=="" (
    echo ERROR: ANDROID_HOME environment variable is not set!
    echo Please run setup_env.bat first to set environment variables.
    echo Expected: ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\sdk
    exit /b 1
)

@rem التحقق من وجود ملف gradle.bat
set GRADLE_CMD=%GRADLE_HOME%\bin\gradle.bat
if not exist "%GRADLE_CMD%" (
    echo ERROR: Gradle executable not found at: %GRADLE_CMD%
    echo Please verify GRADLE_HOME path.
    exit /b 1
)

echo Using GRADLE_HOME: %GRADLE_HOME%
echo Using JAVA_HOME: %JAVA_HOME%
echo Using ANDROID_HOME: %ANDROID_HOME%
echo.

@rem تشغيل Gradle مع جميع المعاملات المرسلة
echo Running: "%GRADLE_CMD%" %*
echo.
"%GRADLE_CMD%" %*

@rem حفظ كود الخروج
set GRADLE_EXIT_CODE=%ERRORLEVEL%

if "%OS%"=="Windows_NT" endlocal

exit /b %GRADLE_EXIT_CODE%
