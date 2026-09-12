# VoidOS - Install and apply macOS cursors
# NOTE: the bundled Install.inf uses rundll32 syssetup.dll SetupInfObjectInstallAction,
# which shows an "installazione non riuscita" dialog when run elevated and BLOCKS the
# playbook. We apply the exact same registry values directly instead (no popups).

$src = "$env:SystemRoot\..\Windows\Cursors\macosCursors-ns-n"
$src = "C:\Windows\Cursors\macosCursors-ns-n"
$dst = "$env:WINDIR\Cursors\macosCursors-ns-n"
$CUR_DIR = "Cursors\macosCursors-ns-n"

Write-Host "Installing macOS cursors to $dst ..."

New-Item -ItemType Directory -Force -Path $dst | Out-Null
$src = "$PSScriptRoot\..\Assets\Cursors\macosCursors-ns-n"
Copy-Item "$src\*" $dst -Recurse -Force

$base = $dst + "\"

$map = [ordered]@{
    Arrow          = "Normal.cur"
    Help           = "Help.cur"
    AppStarting    = "Working.ani"
    Wait           = "Busy.ani"
    IBeam          = "Text.cur"
    No             = "Unavailable.cur"
    SizeNS         = "Vertical Resize.cur"
    SizeWE         = "Horizontal Resize.cur"
    SizeNWSE       = "Diagonal Resize 1.cur"
    SizeNESW       = "Diagonal Resize 2.cur"
    SizeAll        = "Move.cur"
    UpArrow        = "Alternate.cur"
    Crosshair      = "Precision.cur"
    NWPen          = "Handwriting.cur"
    Hand           = "Link.cur"
    Pin            = "Pin.cur"
    Person         = "Person.cur"
    Pan            = "Pan.cur"
    Grab           = "Move.cur"
    Grabbing       = "Closehand.cur"
    "Zoom-in"      = "Zoom-in.cur"
    "Zoom-out"     = "Zoom-out.cur"
}

# Register the scheme so it appears in the pointer settings list
$schemeName = "macOS Cursors - No Shadow Newer"
$schemeValues = @(
    "Normal.cur", "Help.cur", "Working.ani", "Busy.ani", "Precision.cur",
    "Text.cur", "Link.cur", "Unavailable.cur", "Vertical Resize.cur",
    "Horizontal Resize.cur", "Diagonal Resize 1.cur", "Diagonal Resize 2.cur",
    "Move.cur", "Alternate.cur", "Link.cur", "Pin.cur", "Person.cur",
    "Pan.cur", "Move.cur", "Closehand.cur", "Zoom-in.cur", "Zoom-out.cur"
) | ForEach-Object { "$base$_" }

New-Item -Path "HKCU:\Control Panel\Cursors\Schemes" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Control Panel\Cursors\Schemes" -Name $schemeName `
    -Value ($schemeValues -join ",") -PropertyType String -Force | Out-Null

# Apply the individual cursor values
$reg = "HKCU:\Control Panel\Cursors"
foreach ($entry in $map.GetEnumerator()) {
    Set-ItemProperty -Path $reg -Name $entry.Key -Value ($base + $entry.Value) -ErrorAction SilentlyContinue
}
Set-ItemProperty -Path $reg -Name "(default)" -Value $schemeName -ErrorAction SilentlyContinue

Write-Host "Cursor registry values applied. Refreshing cursors..."

# Refresh cursors (SPI_SETCURSORS) - no window, no dialog
Add-Type @"
using System.Runtime.InteropServices;
public class CursorRefresh {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, System.IntPtr lpvParam, int fuWinIni);
}
"@
[void][CursorRefresh]::SystemParametersInfo(0x0057, 0, [System.IntPtr]::Zero, 0x01 -bor 0x02)

Write-Host "macOS cursors installed and applied." -ForegroundColor Green