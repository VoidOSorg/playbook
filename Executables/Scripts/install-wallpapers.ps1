# Installa e imposta sfondi VoidOS
param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath)
    exit
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    INSTALLAZIONE SFONDI VOIDOS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$wallpapersBaseDir = "C:\Users\vdrag\Desktop\VoidOS_Playbook\Resources\Wallpapers"
$wallpapersDest = "C:\VoidOS\Wallpapers"

# Crea cartella destinazione
if (!(Test-Path $wallpapersDest)) {
    New-Item -ItemType Directory -Path $wallpapersDest -Force | Out-Null
    Write-Host "Cartella Wallpapers creata: $wallpapersDest" -ForegroundColor Yellow
}

# COPIA TUTTI GLI SFONDI (sia Dark che Light)
if (Test-Path $wallpapersBaseDir) {
    # Copia tutto l'albero delle cartelle
    Copy-Item -Path "$wallpapersBaseDir\*" -Destination $wallpapersDest -Recurse -Force
    Write-Host "✓ Tutti gli sfondi copiati in $wallpapersDest" -ForegroundColor Green
    
    # IMPOSTA SFONDI DEL TEMA SCURO (default)
    $darkDesktop = "$wallpapersBaseDir\Dark\Desktop\wllppr0.png"
    $darkLockscreen = "$wallpapersBaseDir\Dark\Lockscreen\wllppr1.png"
    
    Write-Host "`nImpostazione tema scuro (default)..." -ForegroundColor Cyan
    
    # Imposta sfondo Desktop
    if (Test-Path $darkDesktop) {
        try {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
            [Wallpaper]::SystemParametersInfo(20, 0, $darkDesktop, 0x01 -bor 0x02)
            Write-Host "✓ Sfondo Desktop impostato: Dark\wllppr0.png" -ForegroundColor Green
        } catch {
            Write-Host "! Errore impostazione Desktop: $_" -ForegroundColor Red
        }
    }
    
    # Imposta sfondo Lockscreen (richiede Windows 10+ e PowerShell 5+)
    if (Test-Path $darkLockscreen) {
        try {
            # Metodo per Windows 10/11
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name LockScreenImage -Value $darkLockscreen -ErrorAction SilentlyContinue
            Write-Host "✓ Sfondo Lockscreen impostato: Dark\wllppr1.png" -ForegroundColor Green
        } catch {
            Write-Host "! Nota: Alcune versioni di Windows richiedono Group Policy per il Lockscreen" -ForegroundColor Yellow
            Write-Host "  Puoi impostarlo manualmente da Impostazioni > Personalizzazione" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nSfondi Light disponibili in:" -ForegroundColor Cyan
    Write-Host "  Desktop: $wallpapersDest\Light\Desktop\wllppr3.png" -ForegroundColor Gray
    Write-Host "  Lockscreen: $wallpapersDest\Light\Lockscreen\wllppr4.png" -ForegroundColor Gray
    
    Write-Host "`nPer cambiare tema, apri: C:\VoidOS\Wallpapers\" -ForegroundColor Cyan
} else {
    Write-Host "! ERRORE: Cartella wallpaper non trovata!" -ForegroundColor Red
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "Completato!" -ForegroundColor Green