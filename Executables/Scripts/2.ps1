# URL dell'immagine da scaricare
$imageUrl = "https://i.imgur.com/fbtqoyF.jpeg"

# Percorso temporaneo dove salvare il file scaricato
$tempImagePath = "$env:TEMP\Wallpaper.png"

# Scarica il file immagine
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $tempImagePath -ErrorAction Stop
    Write-Host "Immagine scaricata con successo: $tempImagePath"
}
catch {
    Write-Error "Errore durante il download dell'immagine: $_"
    Exit 1
}

# Aggiunge la funzione per impostare lo sfondo
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Costanti
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDWININICHANGE = 0x02

# Imposta lo sfondo
$result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $tempImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)

if ($result) {
    Write-Host "Sfondo impostato con successo da: $imageUrl"
    
    # Attende 2 secondi per mostrare il messaggio prima di chiudere
    Start-Sleep -Seconds 2
}
else {
    Write-Error "Errore durante l'impostazione dello sfondo."
    
    # Attende 2 secondi per mostrare il messaggio di errore prima di chiudere
    Start-Sleep -Seconds 2
    Exit 1
}

# Chiude la finestra di PowerShell
Exit