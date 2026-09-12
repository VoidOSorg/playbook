# VoidOS - Disable unnecessary services (batch, with progress)
# Replaces ~90 individual !service actions with a single fast pass.
# Tied to the "remove-defender" checkable option (enabled by default):
#   no switch          -> disables the base list (always)
#   -IncludeDefender   -> disables only the Defender services
param(
    [switch]$IncludeDefender
)

$Global:Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
function Write-Elapsed { "[{0:N1}s] " -f $Global:Stopwatch.Elapsed.TotalSeconds }

if ($IncludeDefender) {
    Write-Host "$(Write-Elapsed) Disabling Windows Defender services (option selected)..." -ForegroundColor Cyan
    $Services = @(
        'WinDefend',
        'WdNisSvc',
        'SecurityHealthService',
        'wscsvc',
        'Sense',
        'WdFilter',
        'WdNisDrv'
    )
} else {
    Write-Host "$(Write-Elapsed) Disabling unnecessary services..." -ForegroundColor Cyan
    $Services = @(
    'SysMain',
    'DiagTrack',
    'dmwappushservice',
    'MapsBroker',
    'PhoneSvc',
    'DPS',
    'WdiServiceHost',
    'WdiSystemHost',
    'diagnosticshub.standardcollector.service',
    'diagsvc',
    'NetBT',
    'WSearch',
    'Spooler',
    'Fax',
    'stisvc',
    'PrintNotify',
    'CscService',
    'MsKeyboardFilter',
    'GameInputSvc',
    'DisplayEnhancementService',
    'WMPNetworkSvc',
    'SensorDataService',
    'RetailDemo',
    'WbioSrvc',
    'lfsvc',
    'DsSvc',
    'AppVClient',
    'NetTcpPortSharing',
    'WPDBusEnum',
    'bthserv',
    'BTAGService',
    'DeviceAssociationService',
    'DevQueryBroker',
    'InstallService',
    'UsoSvc',
    'DoSvc',
    'WpcMonSvc',
    'SessionEnv',
    'RasMan',
    'DusmSvc',
    'SharedAccess',
    'iphlpsvc',
    'IKEEXT',
    'autotimesvc',
    'TimeBrokerSvc',
    'FDResPub',
    'fdPHost',
    'SSDPSRV',
    'Wecsvc',
    'WinRM',
    'RemoteRegistry',
    'RemoteAccess',
    'ShellHWDetection',
    'LanmanServer',
    'TermService',
    'TrkWks',
    'EFS',
    'BDESVC',
    'DsmSvc',
    'SEMgrSvc',
    'DialogBlockingService',
    'uhssvc',
    'TokenBroker',
    'wlidsvc',
    'WMIRegistrationService'
)

# Xbox
$Services += @(
    'XblAuthManager',
    'XblGameSave',
    'XboxNetApiSvc',
    'XboxGipSvc'
)

# Edge updaters (Edge itself is removed later)
$Services += @(
    'edgeupdate',
    'edgeupdatem',
    'gupdate'
)

# BEService (BattlEye) and other game anti-cheat payloads
    $Services += @(
        'BEService'
    )
}

# De-duplicate while preserving order
$Services = $Services | Select-Object -Unique

$total = $Services.Count
$ok = 0
$fail = 0
$i = 0

foreach ($svc in $Services) {
    $i++
    try {
        $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($s) {
            Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
            $ok++
            Write-Host "$(Write-Elapsed)[$i/$total] [OK] $svc"
        } else {
            Write-Host "$(Write-Elapsed)[$i/$total] [skip] $svc (not present)" -ForegroundColor DarkGray
        }
    } catch {
        $fail++
        Write-Host "$(Write-Elapsed)[$i/$total] [FAIL] $svc : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "$(Write-Elapsed) Services done. OK=$ok skip=missing fail=$fail" -ForegroundColor Green