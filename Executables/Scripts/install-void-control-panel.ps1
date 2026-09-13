# VoidOS - Install VoidControlPanel from bundled MSI and pin it to the taskbar
# Any previously installed version (any ProductCode whose DisplayName matches) is
# silently uninstalled before installing the bundled MSI.
$ErrorActionPreference = 'Stop'

$msi = Join-Path $PSScriptRoot "..\VoidOSModules\Executables\VoidControlPanel_setup.msi"

if (-not (Test-Path $msi)) {
    Write-Host "[!] MSI not found: $msi"
    exit 1
}

function ConvertTo-GuidString {
    param([string]$Value)
    try { if ($Value -match '^\{?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\}?$') { return [guid]::new($Value).ToString('B') } } catch {}
    return $Value
}

# --- 1) Silent-uninstall any previous VoidOS Panel / VoidControlPanel version ---
Write-Host "[+] Checking for previously installed VoidControlPanel versions..."

$installed = @()
foreach ($base in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')) {
    foreach ($key in Get-ItemProperty $base -ErrorAction SilentlyContinue) {
        if ($key.DisplayName -and $key.DisplayName -match '(?i)Void(OS)? (Control )?Panel|VoidControlPanel') {
            $code = ConvertTo-GuidString ($key.PSChildName -as [string])
            $installed += [pscustomobject]@{ ProductCode = $code; DisplayName = $key.DisplayName; Version = $key.DisplayVersion }
        }
    }
}

# Also query the old-style GUID installed products via MsiEnumProducts
try {
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $codes = @()
    $i = 0
    do {
        $code = $installer.GetType().InvokeMember('EnumProducts', 'InvokeMethod', $null, $installer, @($i, 0)).ToString()
        if ($code) { $codes += $code; $i++ }
    } while ($code)
    foreach ($code in $codes) {
        $prodKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$code"
        $disp = (Get-ItemProperty $prodKey -ErrorAction SilentlyContinue).DisplayName
        if ($disp -match '(?i)Void(OS)? (Control )?Panel|VoidControlPanel') {
            if (-not ($installed | Where-Object { $_.ProductCode -eq $code })) {
                $installed += [pscustomobject]@{ ProductCode = $code; DisplayName = $disp; Version = '' }
            }
        }
        $wowKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$code"
        $dispWow = (Get-ItemProperty $wowKey -ErrorAction SilentlyContinue).DisplayName
        if ($dispWow -match '(?i)Void(OS)? (Control )?Panel|VoidControlPanel') {
            if (-not ($installed | Where-Object { $_.ProductCode -eq $code })) {
                $installed += [pscustomobject]@{ ProductCode = $code; DisplayName = $dispWow; Version = '' }
            }
        }
    }
}
catch {
    Write-Host "[!] Could not enumerate installed MSI products: $_" -ForegroundColor Yellow
}

$uninstalled = 0
foreach ($p in $installed) {
    $code = $p.ProductCode
    if (-not $code) { continue }
    if ($code -notmatch '^\{[0-9a-fA-F]{8}-') { $code = ConvertTo-GuidString $code }
    if (-not $code) { continue }
    Write-Host "[+] Uninstalling previous version: $($p.DisplayName) ($code) ver $($p.Version)"
    $up = Start-Process msiexec.exe -ArgumentList "/x `"$code`" /qn /norestart" -Wait -PassThru
    Write-Host "[OK] msiexec exit: $($up.ExitCode)"
    $uninstalled++
}

if ($uninstalled -eq 0) {
    Write-Host "[OK] No previous VoidControlPanel version found."
}

# --- 2) Install the bundled MSI ---
Write-Host "[+] Installing VoidControlPanel (silent)..."
$proc = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
Write-Host "[OK] msiexec exit code: $($proc.ExitCode)"

if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
    # 3010 = install OK, reboot required
    Write-Host "[!] Installer returned $($proc.ExitCode)" -ForegroundColor Yellow
}

# --- 3) Remove leftover old executables from known heritage paths ---
$leftovers = @(
    "$env:ProgramFiles\VoidControlPanel.exe",
    "${env:ProgramFiles(x86)}\VoidControlPanel.exe",
    "$env:ProgramFiles\VoidOS Panel\VoidControlPanel.exe",
    "$env:LOCALAPPDATA\VoidOS Panel\VoidControlPanel.exe",
    "$env:LOCALAPPDATA\Programs\VoidControlPanel\VoidControlPanel.exe"
)
foreach ($l in $leftovers) {
    if (Test-Path $l) { Remove-Item $l -Force -ErrorAction SilentlyContinue; Write-Host "[OK] Removed leftover: $l" }
}

# --- 4) Locate the newly installed executable ---
$exe = $null

function Get-InstallLocation {
    param([string]$Root)
    $roots = @(
        "$Root\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "$Root\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($r in $roots) {
        foreach ($key in Get-ItemProperty $r -ErrorAction SilentlyContinue) {
            if ($key.DisplayName -and $key.DisplayName -match 'Void(OS)? (Control )?Panel|VoidControlPanel') {
                if ($key.InstallLocation -and (Test-Path $key.InstallLocation)) {
                    return $key.InstallLocation
                }
            }
        }
    }
    return $null
}

$loc = Get-InstallLocation 'HKLM:'
if (-not $loc) { $loc = Get-InstallLocation 'HKCU:' }

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

# --- 5) Pin to taskbar (same 3-step strategy as pin-taskbar.ps1) ---
& (Join-Path $PSScriptRoot "pin-taskbar.ps1") -Target $exe

Write-Host "VoidControlPanel installed and pinned." -ForegroundColor Green