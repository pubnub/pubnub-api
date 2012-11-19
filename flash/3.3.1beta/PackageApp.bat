@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:menu
echo .
echo Choose what you want
echo [1] normal .AIR
echo [2] Windows
echo [3] MacOS
echo .

:choice
set /P C=[Choice]: 
echo.

set AIR_TARGET=

if "%C%"=="1" call bat\Packager.bat
if "%C%"=="2" call bat\PackagerWin.bat
if "%C%"=="3" call bat\PackagerMacOS.bat

pause