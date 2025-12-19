@echo off

:: ===== Admin check =====
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: ===== Path fisso =====
set OS_DIR=%USERPROFILE%\Desktop\VoidOS-Tweaks\OS
cd /d "%OS_DIR%" || exit

echo Using directory:
echo %OS_DIR%
echo.

:: ===== Brave =====
if exist BraveBrowserSetup-BRV013.exe (
    BraveBrowserSetup-BRV013.exe /silent /install
)

:: ===== Registry =====
if exist fix.reg (
    reg import fix.reg
)

:: ===== Power plan =====
if exist VoidOS_Powerplan.pow (
    powercfg -import VoidOS_Powerplan.pow e01699a2-5a48-4399-891b-d130db7cdb3e
    powercfg -setactive e01699a2-5a48-4399-891b-d130db7cdb3e
)

:: ===== Wallpaper =====
if exist WALLPAPER.ps1 (
    powershell -ExecutionPolicy Bypass -File WALLPAPER.ps1
)

echo.
echo VoidOS setup completed.
pause
