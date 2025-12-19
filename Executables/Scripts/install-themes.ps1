# Installa temi VoidOS
param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    exit
}

Write-Host "Installazione temi VoidOS..." -ForegroundColor Cyan

$themePath = "C:\Users\vdrag\Desktop\PlaybookVoid\Resources\Themes\DarkTheme.xml"
$themeDest = "$env:WINDIR\Resources\Themes\VoidOS.theme"

if (Test-Path $themePath) {
    Copy-Item -Path $themePath -Destination $themeDest -Force
    Write-Host "Tema VoidOS installato!" -ForegroundColor Green
} else {
    Write-Host "Nessun tema trovato, verrà utilizzato il tema di default" -ForegroundColor Yellow
}