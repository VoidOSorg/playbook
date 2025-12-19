@echo off
TITLE Discord Debloat
echo.
echo.
echo                 Discord Debloat by Quezii
echo.
echo.


TASKKILL /T /F /IM Discord.exe >nul 2>&1
timeout 5 >nul 2>&1

del /f /q %LOCALAPPDATA%\Discord\Discord_updater*, %LOCALAPPDATA%\Discord\SquirrelSetup* >nul 2>&1

cd /d %LOCALAPPDATA%\Discord\app* >nul 2>&1
@REM del /f /q chrome*.pak >nul 2>&1
del /f /q app.ico >nul 2>&1
del /f /q debug.log >nul 2>&1
rmdir /s /q swiftshader >nul 2>&1

:: Languages Cleanup
copy "locales\en-US.pak" "%LOCALAPPDATA%\Discord\" >nul 2>&1
rmdir /s /q "locales" >nul 2>&1
mkdir "locales" >nul 2>&1
move "%LOCALAPPDATA%\Discord\en-US.pak" "locales" >nul 2>&1

:: Modules Cleanup
cd /d %LOCALAPPDATA%\Discord\app*\modules >nul 2>&1
for %%a in (
    "discord_cloudsync-1"
    "discord_dispatch-1"
    "discord_erlpack-1"
    "discord_game_utils-1"
    "discord_game_utils-2"
    "discord_media-1"
    "discord_media-2"
    "discord_spellcheck-1"
    "discord_hook-1"
    "discord_hook-2"
) do (
    if exist "%%~a" (
        rmdir /s /q "%%~a" >nul 2>&1
        echo        Removed %%~a
    )
)

echo.
echo            Would you like to remove overlay? [Y/N]
CHOICE /C YN >nul 2>&1
IF %ERRORLEVEL% EQU 1 (
    for %%b in (
        "discord_rpc-1"
        "discord_overlay-1"
        "discord_overlay2-1"
        "discord_overlay2-2"
    ) do (
        if exist "%%~b" (
            rmdir /s /q "%%~b" >nul 2>&1
            echo        Removed %%~b
        )
    )
) ELSE (
    echo.
    echo                    Overlay won't be removed.
)
echo.
echo.
echo    If Discord does not start in the future, reinstall it from the internet.

timeout 3 >nul 2>&1