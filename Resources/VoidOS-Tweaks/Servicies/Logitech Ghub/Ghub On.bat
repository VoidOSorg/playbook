@echo off
cls
echo                  Enabling G Hub
sc config LGHUBUpdaterService start= auto >nul 2>&1
sc start LGHUBUpdaterService >nul 2>&1
sc config LGHUBService start= auto >nul 2>&1
sc start LGHUBService >nul 2>&1
sc config LGS start= auto >nul 2>&1
sc start LGS >nul 2>&1
timeout /t 1 >nul
