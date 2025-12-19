@echo off
cls
echo                  Disabling G Hub
sc stop LGHUBUpdaterService >nul 2>&1
sc config LGHUBUpdaterService start= disabled >nul 2>&1
sc stop LGHUBService >nul 2>&1
sc config LGHUBService start= disabled >nul 2>&1
sc stop LGS >nul 2>&1
sc config LGS start= disabled >nul 2>&1
timeout /t 1 >nul
