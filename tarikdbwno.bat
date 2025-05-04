@echo off
setlocal

:: Ganti sesuai dengan nama package dan database
set PACKAGE_NAME=com.aadhk.restpos
set DB_NAME=restpos.db
set DEST_PATH=%USERPROFILE%\Desktop\backup_db

echo Menyalin database %DB_NAME% dari %PACKAGE_NAME%...

if not exist "%DEST_PATH%" (
    mkdir "%DEST_PATH%"
)

:: Tarik langsung isi database pakai exec-out dan simpan
adb exec-out run-as %PACKAGE_NAME% cat /data/data/%PACKAGE_NAME%/databases/%DB_NAME% > "%DEST_PATH%\%DB_NAME%"

echo.
if exist "%DEST_PATH%\%DB_NAME%" (
    echo ✅ Database berhasil disalin ke: %DEST_PATH%\%DB_NAME%
) else (
    echo ❌ Gagal menyalin database. Mungkin app tidak debuggable atau adb tidak punya akses.
)

pause
endlocal
