@echo off
title VoidOS - Disabilitazione Servizi Veloce

set SERVICES=UserDataSvc_363d9 stisvc "AMD Crash Defender Service" "AMD External Events Utility" UnistoreSvc_363d9 wlidsvc BEService wscsvc SharedAccess SessionEnv RasMan DusmSvc WpcMonSvc PimIndexMaintenanceSvc_363d9 DevicesFlowUserSvc_363d9 diagsvc DialogBlockingService EFS EpicOnlineServices PrintNotify Fax CscService MsKeyboardFilter GameInputSvc TokenBroker XblAuthManager DsmSvc SEMgrSvc WinRM DevQueryBroker XblGameSave GoogleChromeElevationService iphlpsvc fdPHost SSDPSRV jhi_service WMIRegistrationService TrkWks AppVClient edgeupdate edgeupdatem uhssvc IKEEXT ssh-agent autotimesvc W32Time DoSvc FDResPub Wecsvc RemoteRegistry ShellHWDetection RemoteAccess LanmanServer TermService diagnosticshub.standardcollector.service DeviceAssociationService BthAvctpSvc FontCache WdNisSvc SensorDataService RetailDemo WbioSrvc DsSvc WMPNetworkSvc NetTcpPortSharing BDESVC lfsvc InstallService DisplayEnhancementService UsoSvc XboxNetApiSvc bthserv WPDBusEnum BTAGService gupdate

for %%S in (%SERVICES%) do sc config "%%~S" start= disabled >nul 2>&1

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1

exit /b 0