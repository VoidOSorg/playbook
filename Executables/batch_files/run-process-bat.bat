@echo off
REM Script per ottimizzazione processi 35-45 Processi.bat
echo Ottimizzazione processi in esecuzione...

REM Se hai un file specifico 35-45 Processi.bat
if exist "%~dp035-45 Processi.bat" (
    call "%~dp035-45 Processi.bat"
) else (
    echo File 35-45 Processi.bat non trovato
    pause
)