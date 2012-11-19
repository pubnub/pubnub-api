@echo off
if not exist %CERT_FILE% goto certificate

:: Package
echo.
echo Packaging Air EXECUTEABLE %AIR_NAME% using certificate %CERT_FILE%...
call adt -package %SIGNING_OPTIONS% -target native %AIR_PATH%\%AIR_NAME%.dmg %APP_XML% %FILE_OR_DIR%

if errorlevel 1 goto failed
goto end

:certificate
echo.
echo Certificate not found: %CERT_FILE%
echo.
echo Troubleshooting: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo AIR setup creation FAILED.
echo.
echo Troubleshooting: 
echo - did you build your project in FlashDevelop?
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
echo.