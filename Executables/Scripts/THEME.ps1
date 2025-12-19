param (
    [Parameter(Mandatory = $true, ParameterSetName = 'SetExistingTheme')]
    [string]$Path,

    [Parameter(Mandatory = $true, ParameterSetName = 'NewCustomTheme')]
    [hashtable]$New
)

if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator."
    exit 1
}

function Apply-VoidOSVisualTweaks {
    param ([string]$Sid)

    $base = "Registry::HKEY_USERS\$Sid"

    # =========================
    # DARK MODE
    # =========================
    New-Item "$base\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null

    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        SystemUsesLightTheme 0 -Type DWord
    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        AppsUseLightTheme 0 -Type DWord

    # =========================
    # NO TRANSPARENCY
    # =========================
    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        EnableTransparency 0 -Type DWord

    # =========================
    # BEST PERFORMANCE (NO ANIMATIONS / PEEK / SHADOWS)
    # =========================
    Set-ItemProperty "$base\Control Panel\Desktop" `
        UserPreferencesMask ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

    Set-ItemProperty "$base\Control Panel\Desktop\WindowMetrics" `
        MinAnimate "0" -Type String

    Set-ItemProperty "$base\Software\Microsoft\Windows\DWM" `
        EnableAeroPeek 0 -Type DWord

    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        TaskbarAnimations 0 -Type DWord

    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        ListviewAlphaSelect 0 -Type DWord

    Set-ItemProperty "$base\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        ListviewShadow 0 -Type DWord
}

function Set-ExistingTheme {
    param ([string]$ThemePath)

    if (-not (Test-Path $ThemePath)) {
        Write-Error "Theme not found: $ThemePath"
        exit 1
    }

    Get-ChildItem Registry::HKEY_USERS | ForEach-Object {
        $sid = $_.PSChildName
        if ($sid -notmatch '(_Classes|^\.DEFAULT$)') {

            New-Item "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Themes" -Force | Out-Null
            Set-ItemProperty `
                "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Themes" `
                CurrentTheme $ThemePath

            Apply-VoidOSVisualTweaks -Sid $sid
        }
    }
}

function New-CustomTheme {
    param ([hashtable]$Config)

    $wallpaper = $Config['WallpaperPath']
    $export = $Config['ThemeExportPath'] ?? "$env:SystemRoot\Resources\Themes\voidos.theme"
    $base = "$env:SystemRoot\Resources\Themes\dark.theme"

    Copy-Item $base $export -Force

    (Get-Content $export) | ForEach-Object {
        if ($_ -match '^Wallpaper=') { "Wallpaper=$wallpaper" }
        else { $_ }
    } | Set-Content $export

    Set-ExistingTheme -ThemePath $export
}

switch ($PSCmdlet.ParameterSetName) {
    'SetExistingTheme' { Set-ExistingTheme -ThemePath $Path }
    'NewCustomTheme'   { New-CustomTheme -Config $New }
}
