@echo off
title SPOTIFY DEBLOATER 
echo SPOTIFY DEBLOATER 

cd /d "%APPDATA%\Spotify" >NUL 2>&1
copy "%APPDATA%\Spotify\locales\en-US.pak" "%APPDATA%\Spotify" >NUL 2>&1
rmdir "%APPDATA%\Spotify\locales" /s /q >NUL 2>&1
mkdir "%APPDATA%\Spotify\locales" >NUL 2>&1
move "%APPDATA%\Spotify\en-US.pak" "%APPDATA%\Spotify\locales" >NUL 2>&1

:: del /f chrome_1*.*, chrome_2*.*, crash*.*, SpotifyMigrator.exe, SpotifyStartupTask.exe, d3d*.*, debug.log, libegl.dll, libgle*.*, snapshot*.*, vk*.*, vulkan*.* >NUL 2>&1