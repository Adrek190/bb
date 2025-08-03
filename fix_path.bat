@echo off
echo Current PATH:
echo %PATH%

echo.
echo Cleaning up PATH...

:: Remove duplicate paths
set "NEWPATH="
for %%i in ("%PATH:;=" "%") do (
    if defined NEWPATH (
        echo !NEWPATH! | findstr /C:"%%~i" >nul
        if errorlevel 1 set "NEWPATH=!NEWPATH!;%%~i"
    ) else (
        set "NEWPATH=%%~i"
    )
)

echo.
echo New PATH would be:
echo %NEWPATH%

echo.
echo To apply these changes permanently, run as administrator:
echo setx PATH "%NEWPATH%" /M

pause
