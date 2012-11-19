:user_configuration

:: Path to Flex SDK
set FLEX_SDK=C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0


:validation
if not exist "%FLEX_SDK%\bin" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo Looking for: %FLEX_SDK%\bin
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%PATH%;%FLEX_SDK%\bin

