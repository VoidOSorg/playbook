# URL dell'immagine da scaricare
$imageUrl = "https://i.imgur.com/RHxUbrZ.png"

# Percorso temporaneo dove salvare il file scaricato
$tempImagePath = "$env:TEMP\Wallpaper.png"

# Scarica il file immagine
Invoke-WebRequest -Uri $imageUrl -OutFile $tempImagePath

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
} else {
    Write-Error "Errore durante l'impostazione dello sfondo."
}
