# Script VoidOS - Configurazione Completa
# Deve essere eseguito come amministratore

# ============================================
# 1. IMPOSTAZIONE SFONDO DESKTOP
# ============================================

Write-Output "=== Impostazione Sfondo Desktop ==="

$imageUrl = "https://i.imgur.com/fbtqoyF.jpeg"
$tempImagePath = "$env:TEMP\Wallpaper.png"

try {
    # Scarica il file immagine
    Invoke-WebRequest -Uri $imageUrl -OutFile $tempImagePath -ErrorAction Stop
    Write-Output "  ✓ Immagine scaricata: $imageUrl"
    
    # Aggiunge la funzione per impostare lo sfondo
    Add-Type @"
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@ -ErrorAction Stop

    # Costanti
    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDWININICHANGE = 0x02

    # Imposta lo sfondo
    $result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $tempImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)

    if ($result) {
        Write-Output "  ✓ Sfondo impostato con successo"
    } else {
        Write-Output "  ⚠ Errore durante l'impostazione dello sfondo"
    }
}
catch {
    Write-Output "  ⚠ Errore nell'impostazione dello sfondo: $($_.Exception.Message)"
}

# ============================================
# 2. IMPOSTAZIONI REGISTRO - MODALITÀ SCURA
# ============================================

Write-Output "`n=== Impostazioni Modalità Scura ==="

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

try {
    # Crea la chiave se non esiste
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Output "  ✓ Creata chiave di registro: $regPath"
    }
    
    # Imposta i valori per la modalità scura
    Set-ItemProperty -Path $regPath -Name "EnableTransparency" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $regPath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $regPath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
    
    Write-Output "  ✓ Modalità scura applicata"
}
catch {
    Write-Output "  ⚠ Errore nell'impostazione del registro: $($_.Exception.Message)"
}

# ============================================
# 3. IMPORT POWER PLAN VOIDOS
# ============================================

Write-Output "`n=== Configurazione Power Plan ==="

# Cerca il file .pow nella stessa directory dello script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$powFile = Join-Path $scriptDir "VoidOS_Powerplan.pow"

if (Test-Path $powFile) {
    try {
        Write-Output "  ✓ File power plan trovato: $powFile"
        
        # Importa il power plan
        $importResult = powercfg -import "$powFile" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Output "  ✓ Power plan importato"
            
            # Ottieni il GUID del piano importato
            $plans = powercfg -list 2>&1
            $guid = ($plans | Select-String "VoidOS") -replace '.*\s+([a-fA-F0-9\-]{36}).*', '$1'
            
            if ($guid -match '^[a-fA-F0-9\-]{36}$') {
                # Attiva il piano
                powercfg -setactive $guid 2>&1 | Out-Null
                Write-Output "  ✓ Power Plan VoidOS attivato (GUID: $guid)"
            }
            else {
                Write-Output "  ⚠ GUID non trovato, attivazione manuale richiesta"
            }
        }
        else {
            Write-Output "  ⚠ Errore nell'importazione del power plan"
        }
    }
    catch {
        Write-Output "  ⚠ Errore nella configurazione del power plan: $($_.Exception.Message)"
    }
}
else {
    Write-Output "  ⚠ File VoidOS_Powerplan.pow non trovato in: $scriptDir"
    Write-Output "    Salta questa sezione..."
}

# ============================================
# 4. INSTALLAZIONE BRAVE BROWSER
# ============================================

Write-Output "`n=== Installazione Brave Browser ==="

# Percorso specifico: Desktop\VoidOS-Tweaks\OS\
$braveSetupPath = "$env:USERPROFILE\Desktop\VoidOS-Tweaks\OS\BraveBrowserSetup-BRV013.exe"

Write-Output "  Cercando Brave in: $braveSetupPath"

if (Test-Path $braveSetupPath) {
    try {
        Write-Output "  ✓ File Brave trovato"
        Write-Output "  Avvio installazione Brave Browser..."
        
        # Parametri per installazione silenziosa
        $braveArgs = "--silent"
        
        # Esegui l'installazione
        $process = Start-Process -FilePath $braveSetupPath -ArgumentList $braveArgs -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Output "  ✓ Brave Browser installato con successo"
        }
        else {
            Write-Output "  ⚠ Installazione completata con codice uscita: $($process.ExitCode)"
        }
    }
    catch {
        Write-Output "  ⚠ Errore durante l'installazione di Brave: $($_.Exception.Message)"
    }
}
else {
    Write-Output "  ⚠ File BraveBrowserSetup-BRV013.exe non trovato"
    Write-Output "    Percorso atteso: $braveSetupPath"
    Write-Output "    Verifica che il file esista in questa posizione"
}

# ============================================
# 5. DISINSTALLAZIONE APP WINDOWS
# ============================================

Write-Output "`n=== Disinstallazione App Windows ==="

# Lista delle app da disinstallare
$appsToRemove = @(
    # 3D Viewer
    "Microsoft.Microsoft3DViewer",
    
    # Copilot (Windows 11)
    "Microsoft.Windows.AICopilot.Prototype",
    "Microsoft.Windows.AICopilot",
    
    # Cortana
    "Microsoft.549981C3F5F10",
    
    # Feedback Hub
    "Microsoft.WindowsFeedbackHub",
    
    # Maps
    "Microsoft.WindowsMaps",
    
    # Mail and Calendar
    "microsoft.windowscommunicationsapps",
    
    # OneDrive
    "Microsoft.OneDriveSync",
    
    # Microsoft Edge
    "Microsoft.MicrosoftEdge.Stable",
    "Microsoft.MicrosoftEdge",
    
    # Film e TV
    "Microsoft.ZuneVideo",
    
    # OneNote
    "Microsoft.Office.OneNote",
    
    # Office hub
    "Microsoft.MicrosoftOfficeHub",
    
    # Outlook
    "Microsoft.Office.Outlook",
    
    # Paint
    "Microsoft.Paint",
    
    # People
    "Microsoft.People",
    
    # Skype
    "Microsoft.SkypeApp",
    
    # Solitario
    "Microsoft.MicrosoftSolitaireCollection",
    
    # Sticky Notes
    "Microsoft.MicrosoftStickyNotes",
    
    # Meteo
    "Microsoft.BingWeather",
    
    # Windows Clock
    "Microsoft.WindowsAlarms",
    
    # Xbox apps
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxGameCallableUI"
)

$removedCount = 0
$notFoundCount = 0

foreach ($app in $appsToRemove) {
    try {
        # Rimuove per tutti gli utenti
        $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        if ($packages) {
            $packages | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            $removedCount++
            Write-Output "  ✓ Rimosso: $app"
        }
        else {
            $notFoundCount++
            Write-Output "  - Non trovato: $app"
        }
        
        # Rimuove pacchetti provisioned
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
            Where-Object {$_.DisplayName -like "*$app*"} | 
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            
    }
    catch {
        Write-Output "  ⚠ Errore con $app: $($_.Exception.Message)"
    }
}

# ============================================
# 6. RIEPILOGO E CHIUSURA
# ============================================

Write-Output "`VoidOS Configurated"


Start-Sleep -Seconds 5
exit 0