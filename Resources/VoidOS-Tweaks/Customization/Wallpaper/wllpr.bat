@echo off
chcp 65001 >nul
title Selettore Wallpaper

:menu
cls
echo ===============================
echo    SELEZIONA WALLPAPER
echo ===============================
echo.
echo [1] Black Wallpaper
echo [2] White Wallpaper 
echo [3] Black With Logo
echo [4] White With Logo
echo [5] Esci
echo.
set /p scelta="Scegli un'opzione (1-5): "

if "%scelta%"=="1" goto black
if "%scelta%"=="2" goto white
if "%scelta%"=="3" goto black_logo
if "%scelta%"=="4" goto white_logo
if "%scelta%"=="5" goto exit
echo Scelta non valida! Premere un tasto per continuare...
pause >nul
goto menu

:black
echo Impostando Black Wallpaper...
powershell -Command "Invoke-WebRequest -Uri 'https://i.imgur.com/fbtqoyF.jpeg' -OutFile '%TEMP%\temp_wallpaper.jpg'" >nul 2>&1
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, '%TEMP%\temp_wallpaper.jpg', 3)" >nul 2>&1
echo Wallpaper nero impostato con successo!
timeout /t 2 >nul
goto menu

:white
echo Impostando White Wallpaper...
powershell -Command "Invoke-WebRequest -Uri 'https://i.imgur.com/DTODig1.jpeg' -OutFile '%TEMP%\temp_wallpaper.jpg'" >nul 2>&1
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, '%TEMP%\temp_wallpaper.jpg', 3)" >nul 2>&1
echo Wallpaper bianco impostato con successo!
timeout /t 2 >nul
goto menu

:black_logo
echo Impostando Black With Logo...
powershell -Command "Invoke-WebRequest -Uri 'https://i.imgur.com/ByBWLxZ.jpeg' -OutFile '%TEMP%\temp_wallpaper.jpg'" >nul 2>&1
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, '%TEMP%\temp_wallpaper.jpg', 3)" >nul 2>&1
echo Wallpaper nero con logo impostato con successo!
timeout /t 2 >nul
goto menu

:white_logo
echo Impostando White With Logo...
powershell -Command "Invoke-WebRequest -Uri 'https://i.imgur.com/RHxUbrZ.png' -OutFile '%TEMP%\temp_wallpaper.jpg'" >nul 2>&1
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, '%TEMP%\temp_wallpaper.jpg', 3)" >nul 2>&1
echo Wallpaper bianco con logo impostato con successo!
timeout /t 2 >nul
goto menu

:exit
echo Arrivederci!
timeout /t 1 >nul
exit