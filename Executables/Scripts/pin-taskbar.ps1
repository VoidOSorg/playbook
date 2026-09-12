param(
    [Parameter(Mandatory = $true)]
    [string]$Target
)

# =========================================================
# VoidOS - reliable taskbar pin for Windows 10
# Strategy (in order, each verified before falling through):
#   1) ParseName().InvokeVerb('pin to tas&kbar')  - works on
#      many Windows 10 builds without process tricks
#   2) ExplorerCommandHandler ('Windows.taskbarpin') via a
#      powershell.exe copy named "explorer.exe" (hack from
#      stevencohn/Atlas - pin handler needs an "explorer")
#   3) Plain .lnk drop into User Pinned\TaskBar (last resort,
#      explorer rebuilds the band from these after restart)
# Progress is written on every step so the wizard never
# looks frozen.
# =========================================================

$ErrorActionPreference = 'Continue'
$TaskBarDir  = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$verbPinned  = $false

function Test-NewPin {
    param([string]$Name)
    return (Test-Path (Join-Path $TaskBarDir $Name))
}

# ---------- Method 1: local shell verb ----------
function Invoke-ShellVerb {
    param([string]$T)
    $before = @(Get-ChildItem $TaskBarDir -Filter '*.lnk' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    try {
        $item = Get-Item -LiteralPath $T -ErrorAction Stop
        $shell = New-Object -ComObject 'Shell.Application'
        $folder = $shell.Namespace($item.DirectoryName)
        $node = $folder.ParseName($item.Name)
        if ($node) { $node.InvokeVerb('pin to tas&kbar') }
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)
        Start-Sleep -Milliseconds 1200
    } catch {
        Write-Host "  [warn] invoke-verb failed: $_"
    }
    $after = @(Get-ChildItem $TaskBarDir -Filter '*.lnk' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    $diff = @($after | Where-Object { $_ -notin $before })
    return $diff
}

# ---------- Method 2: ExplorerCommandHandler via explorer-named process ----------
function Invoke-CommandStore {
    param([string]$T)
    $baseKey  = 'HKCU:\SOFTWARE\Classes\*'
    $shellKey = "$baseKey\shell"
    $verbKey  = "$shellKey\Voidospin"
    try {
        $handler = (Get-ItemProperty `
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin' `
            -Name ExplorerCommandHandler -ErrorAction Stop).ExplorerCommandHandler
    } catch {
        Write-Host "  [warn] no Windows.taskbarpin handler found"
        return
    }
    New-Item $verbKey -Force | Out-Null
    Set-ItemProperty $verbKey -Name 'ExplorerCommandHandler' -Value $handler

    $scriptBlock = @"
        `$item = Get-Item -LiteralPath '$T' -ErrorAction Stop
        `$shell = New-Object -ComObject 'Shell.Application'
        `$folder = `$shell.Namespace(`$item.DirectoryName)
        `$node = `$folder.ParseName(`$item.Name)
        if (`$node) { `$null = `$node.InvokeVerb('Voidospin') }
        Start-Sleep -Milliseconds 800
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject(`$shell)
"@

    # Only the handler trick when we are NOT already running as "explorer"
    if ((Get-Process -Id $PID).ProcessName -eq 'explorer') {
        & { Invoke-Expression $scriptBlock }
    } else {
        # The CommandStore handler requires a process literally named "explorer",
        # so relaunch through a copy of powershell.exe called explorer.exe
        $srcExe = Join-Path $PSHOME 'powershell.exe'
        $candidate = Join-Path $env:TEMP 'VoidOS-explorer.exe'
        try {
            Copy-Item $srcExe $candidate -Force
            $fake = Join-Path ($env:TEMP -replace '\\$', '') 'explorer.exe'
            Copy-Item $candidate $fake -Force
            & $fake -NoProfile -ExecutionPolicy Bypass -Command $scriptBlock 2>$null | Out-Null
        } catch {
            Write-Host "  [warn] ExplorerCommandHandler trick failed: $_"
        } finally {
            Remove-Item $fake, $candidate -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-Item $verbKey -Force -ErrorAction SilentlyContinue
    if ((Test-Path $shellKey) -and ((Get-Item $shellKey).SubKeyCount -eq 0) -and ((Get-Item $shellKey).ValueCount -eq 0)) {
        Remove-Item $shellKey -Force -ErrorAction SilentlyContinue
    }
}

# ---------- Method 3: plain .lnk droppoint ----------
function Invoke-LnkDrop {
    param([string]$T)
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $lnkName = [System.IO.Path]::GetFileNameWithoutExtension($T) + '.lnk'
        $sc = $wsh.CreateShortcut((Join-Path $TaskBarDir $lnkName))
        $sc.TargetPath = $T
        $sc.Save()
        Write-Host "  [ok] fallback link created: $lnkName"
    } catch {
        Write-Host "  [fail] could not create fallback link: $_"
    }
}

# ==========================
Write-Host "Pinning: $Target"

$methods = @('verb', 'commandstore', 'lnkdrop')
foreach ($m in $methods) {
    if (Test-NewPin ([System.IO.Path]::GetFileName($Target))) {
        Write-Host "  [ok] already pinned."
        $verbPinned = $true
        break
    }
    switch ($m) {
        'verb' {
            Write-Host "  [1/3] trying local shell verb..."
            $new = Invoke-ShellVerb $Target
            if ($new) { Write-Host "  [ok] pinned via verb ($($new -join ', '))."; $verbPinned = $true }
        }
        'commandstore' {
            Write-Host "  [2/3] trying ExplorerCommandHandler (explorer trick)..."
            Invoke-CommandStore $Target
            Start-Sleep -Milliseconds 800
            $lnk = Join-Path $TaskBarDir ([System.IO.Path]::GetFileNameWithoutExtension($Target) + '.lnk')
            if (Test-Path $lnk) { Write-Host "  [ok] pinned via command handler."; $verbPinned = $true }
        }
        'lnkdrop' {
            Write-Host "  [3/3] falling back to .lnk drop..."
            Invoke-LnkDrop $Target
            $verbPinned = $true
        }
    }
    if ($verbPinned) { break }
}

if (-not $verbPinned) {
    Write-Host "  [!!] pinning failed." -ForegroundColor Yellow
}