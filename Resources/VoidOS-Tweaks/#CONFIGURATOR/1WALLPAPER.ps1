# Script VoidOS - Impostazione Sfondo Desktop
# Deve essere eseguito come amministratore

Write-Output "=== VoidOS - Impostazione Sfondo Desktop ==="

$imageUrl = "https://i.imgur.com/fbtqoyF.jpeg"
$tempImagePath = "$env:TEMP\Wallpaper.png"

try {
    # Scarica il file immagine
    Write-Output "  Scaricamento immagine da: $imageUrl"
    Invoke-WebRequest -Uri $imageUrl -OutFile $tempImagePath -ErrorAction Stop
    Write-Output "  ✓ Immagine scaricata: $tempImagePath"
    
    # Aggiunge la funzione per impostare lo sfondo
    Add-Type @"
using System;
using System.Runtime.InteropServices;
namespace Wallpaper {
    public class Setter {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        
        public static bool SetWallpaper(string path) {
            const int SPI_SETDESKWALLPAPER = 0x0014;
            const int SPIF_UPDATEINIFILE = 0x01;
            const int SPIF_SENDWININICHANGE = 0x02;
            
            int result = SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
            return result != 0;
        }
    }
}
"@ -ErrorAction Stop

    # Imposta lo sfondo
    $result = [Wallpaper.Setter]::SetWallpaper($tempImagePath)

    if ($result) {
        Write-Output "  ✓ Sfondo impostato con successo"
        
        # Imposta anche per il lock screen (opzionale)
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "LockScreenImage" -Value $tempImagePath -ErrorAction SilentlyContinue
            Write-Output "  ✓ Immagine lock screen impostata"
        }
        catch {
            Write-Output "  ⚠ Impossibile impostare lock screen (richiede policy)"
        }
    } 
    else {
        Write-Output "  ⚠ Errore durante l'impostazione dello sfondo"
    }
}
catch {
    Write-Output "  ⚠ Errore nell'impostazione dello sfondo: $($_.Exception.Message)"
    Write-Output "  Tentativo metodo alternativo..."
    
    # Metodo alternativo
    try {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $tempImagePath -ErrorAction Stop
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
        Write-Output "  ✓ Sfondo impostato (metodo alternativo)"
    }
    catch {
        Write-Output "  ✗ Errore critico: $($_.Exception.Message)"
    }
}

Write-Output "`n=== Operazione completata ==="
Start-Sleep -Seconds 3