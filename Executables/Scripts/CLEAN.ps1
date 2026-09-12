param()

<#
===========================================================
VoidOS - Clean Taskbar (automated)
- Unpins EVERYTHING from the taskbar
- Restores default system tray (clock, network, volume, ...)
- Pins File Explorer
- Pins the selected browser (auto-detected: if a VoidOS
  bundled browser is installed it is used; otherwise the
  OS default browser is pinned)
===========================================================
#>

# --- AUTO ELEVATION ---
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    Exit
}

$QL  = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
$TB  = "$QL\User Pinned\TaskBar"

$Global:Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
function Write-Elapsed { "[{0:N1}s] " -f $Global:Stopwatch.Elapsed.TotalSeconds }
Write-Host "$(Write-Elapsed) Starting clean taskbar..." -ForegroundColor Cyan

function Resolve-Browser {
    param([string]$Name)
    $candidates = @()
    switch ($Name.ToLower()) {
        'brave'   { $candidates = @("$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe", "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe") }
        'chrome'  { $candidates = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe") }
        'firefox' { $candidates = @("$env:ProgramFiles\Mozilla Firefox\firefox.exe", "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe") }
        'edge'    { $candidates = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") }
    }
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    return $null
}

function Get-BundledBrowserExe {
    # Prefer the browser the user selected in AME (it was installed in browsers.yml)
    foreach ($name in @('brave', 'chrome', 'firefox', 'edge')) {
        $p = Resolve-Browser $name
        if ($p) { return $p }
    }
    return $null
}

function Get-DefaultBrowserExe {
    # Best effort: read the registered http UserChoice ProgId
    try {
        $progId = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name ProgId -ErrorAction Stop).ProgId
    } catch { return $null }
    $map = @{
        'BraveHTML' = 'brave'
        'BraveHTM'  = 'brave'
        'ChromeHTML' = 'chrome'
        'FirefoxURL' = 'firefox'
        'MSEdgeHTM'  = 'edge'
    }
    foreach ($k in $map.Keys) {
        if ($progId -like "$k*") { return (Resolve-Browser $map[$k]) }
    }
    return $null
}

# ================================
# 1) UNPIN EVERYTHING
# ================================
Write-Host "$(Write-Elapsed)[1/4] Unpinning everything..."
cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"

Remove-Item -Recurse -Force $QL -ErrorAction SilentlyContinue | Out-Null
New-Item "$env:APPDATA\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -Force | Out-Null
New-Item "$TB" -ItemType Directory -Force | Out-Null
New-Item "$QL\User Pinned\ImplicitAppShortcuts" -ItemType Directory -Force | Out-Null

# ================================
# 2) PIN FILE EXPLORER
# ================================
Write-Host "$(Write-Elapsed)[2/4] Pinning File Explorer..."
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$TB\File Explorer.lnk")
$Shortcut.TargetPath = "explorer.exe"
$Shortcut.Save()

# ================================
# 3) PIN BROWSER
# ================================
Write-Host "$(Write-Elapsed)[3/4] Resolving browser to pin..."
# Preferred: the browser the user chose (installed in browsers.yml).
# Fallback: the OS default browser (user kept their own browser).
$browserPath = Get-BundledBrowserExe
if (-not $browserPath) { $browserPath = Get-DefaultBrowserExe }

if ($browserPath -and (Test-Path $browserPath)) {
    Write-Host "$(Write-Elapsed) Pinning browser: $browserPath"
    $pinScript = Join-Path $PSScriptRoot 'pin-taskbar.ps1'
    if (Test-Path $pinScript) {
        & $pinScript -Target $browserPath
    } else {
        # fallback: plain shortcut
        $script:Shortcut = $WshShell.CreateShortcut("$TB\$([System.IO.Path]::GetFileNameWithoutExtension($browserPath)).lnk")
        $script:Shortcut.TargetPath = $browserPath
        $script:Shortcut.Save()
    }
} else {
    Write-Host "$(Write-Elapsed) No browser to pin (none selected / not installed). Skipping." -ForegroundColor Yellow
}

# ================================
# 4) RESTART EXPLORER
# ================================
Write-Host "$(Write-Elapsed)[4/4] Restarting Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer.exe

Write-Host "$(Write-Elapsed) Clean Taskbar Applied. Explorer restarted." -ForegroundColor Green