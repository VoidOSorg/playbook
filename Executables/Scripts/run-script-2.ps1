# Script di ottimizzazione prestazioni
param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    exit
}

Write-Host "Applicazione ottimizzazioni prestazioni VoidOS..." -ForegroundColor Cyan

# Ottimizzazioni base
Write-Host "1. Ottimizzazione power plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

Write-Host "2. Disabilitazione effetti visivi..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

Write-Host "3. Ottimizzazione prestazioni memoria..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1

Write-Host "Ottimizzazioni applicate con successo!" -ForegroundColor Green