# VoidOS - Install VoidControlPanel from bundled MSI and pin it to the taskbar
$ErrorActionPreference = 'Stop'

$msi = Join-Path $PSScriptRoot "..\VoidOSModules\Executables\VoidControlPanel_setup.msi"

if (-not (Test-Path $msi)) {
    Write-Host "[!] MSI not found: $msi"
    exit 1
}

Write-Host "[+] Installing VoidControlPanel (silent)..."
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
Write-Host "[OK] msiexec exit code: $($proc.ExitCode)"

if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
    # 3010 = install OK, reboot required
    Write-Host "[!] Installer returned $($proc.ExitCode)" -ForegroundColor Yellow
}

# Locate the installed executable
$exe = $null

function Get-InstallLocation {
    param(
        [string]$Root,
        [string]$Name
    )
    $roots = @(
        "$Root\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "$Root\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($r in $roots) {
        foreach ($key in Get-ItemProperty $r -ErrorAction SilentlyContinue) {
            if ($key.DisplayName -and $key.DisplayName -match 'VoidControlPanel') {
                if ($key.InstallLocation -and (Test-Path $key.InstallLocation)) {
                    return $key.InstallLocation
                }
            }
        }
    }
    return $null
}

$loc = Get-InstallLocation -Root 'HKLM:' -Name 'VoidControlPanel'
if (-not $loc) { $loc = Get-InstallLocation -Root 'HKCU:' -Name 'VoidControlPanel' }

if ($loc) {
    $exe = Get-ChildItem -Path $loc -Recurse -Filter '*.exe' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'unins|setup|install' } |
        Select-Object -First 1
    if ($exe) { $exe = $exe.FullName }
}

if (-not $exe) {
    # Fallback: scan common install roots
    foreach ($base in @("$env:ProgramFiles", "${env:ProgramFiles(x86)}", "$env:LOCALAPPDATA")) {
        $hit = Get-ChildItem -Path $base -Recurse -Depth 3 -Filter '*VoidControlPanel*.exe' -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($hit) { $exe = $hit.FullName; break }
    }
}

if (-not $exe) {
    Write-Host "[!] Could not locate the installed VoidControlPanel executable." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found executable: $exe"

# Pin to taskbar (same 3-step strategy as pin-taskbar.ps1)
& (Join-Path $PSScriptRoot "pin-taskbar.ps1") -Target $exe

Write-Host "VoidControlPanel installed and pinned." -ForegroundColor Green