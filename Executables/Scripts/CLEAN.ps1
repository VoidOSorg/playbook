# ===============================
# VoidOS - Taskbar Clean (AUTO)
# ===============================

# --- AUTO ELEVATION ---
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent())
    .IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {

    Start-Process PowerShell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    Exit
}

# --- CONSOLE STYLE ---
$Host.UI.RawUI.WindowTitle = "VoidOS Taskbar Clean (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

Write-Host "Applying Clean Taskbar..." -ForegroundColor Cyan

# ===============================
# CLEAN TASKBAR
# ===============================

# Unpin everything
cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"

# Reset Quick Launch
$QL = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch"
Remove-Item -Recurse -Force $QL -ErrorAction SilentlyContinue | Out-Null

New-Item "$env:APPDATA\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -Force | Out-Null
New-Item "$QL\User Pinned\TaskBar" -ItemType Directory -Force | Out-Null
New-Item "$QL\User Pinned\ImplicitAppShortcuts" -ItemType Directory -Force | Out-Null

# Pin File Explorer
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$QL\User Pinned\TaskBar\File Explorer.lnk")
$Shortcut.TargetPath = "explorer.exe"
$Shortcut.Save()

# ===============================
# REG TWEAKS (TASKBAR)
# ===============================

$Reg = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"TaskbarMn"=dword:00000000
"ShowCopilotButton"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=dword:00000000

[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableNotificationCenter"=dword:00000001
"@

$RegPath = "$env:TEMP\VoidOS_Taskbar_Clean.reg"
Set-Content -Path $RegPath -Value $Reg -Encoding ASCII
regedit.exe /s $RegPath

# ===============================
# CLEAN START MENU (W11 SAFE)
# ===============================

$StartBin = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"
Remove-Item $StartBin -Force -ErrorAction SilentlyContinue

# ===============================
# RESTART EXPLORER
# ===============================

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Start-Process explorer.exe

Clear-Host
Write-Host "Clean Taskbar Applied. Restart recommended." -ForegroundColor Green
