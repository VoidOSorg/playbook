$src = "$PSScriptRoot\..\Assets\Cursors\macosCursors-ns-n"
$dst = "$env:WINDIR\Cursors\macosCursors-ns-n"

New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "$src\*" $dst -Recurse -Force

$base = "$dst\"

$reg = "HKCU:\Control Panel\Cursors"

Set-ItemProperty $reg -Name Arrow        -Value ($base + "Normal.cur")
Set-ItemProperty $reg -Name Help         -Value ($base + "Help.cur")
Set-ItemProperty $reg -Name AppStarting  -Value ($base + "Working.ani")
Set-ItemProperty $reg -Name Wait         -Value ($base + "Busy.ani")
Set-ItemProperty $reg -Name IBeam        -Value ($base + "Text.cur")
Set-ItemProperty $reg -Name No           -Value ($base + "Unavailable.cur")
Set-ItemProperty $reg -Name SizeNS       -Value ($base + "Vertical Resize.cur")
Set-ItemProperty $reg -Name SizeWE       -Value ($base + "Horizontal Resize.cur")
Set-ItemProperty $reg -Name SizeNWSE     -Value ($base + "Diagonal Resize 1.cur")
Set-ItemProperty $reg -Name SizeNESW     -Value ($base + "Diagonal Resize 2.cur")
Set-ItemProperty $reg -Name SizeAll      -Value ($base + "Move.cur")
Set-ItemProperty $reg -Name Hand         -Value ($base + "Link.cur")
Set-ItemProperty $reg -Name Crosshair    -Value ($base + "Precision.cur")
Set-ItemProperty $reg -Name NWPen        -Value ($base + "Handwriting.cur")
Set-ItemProperty $reg -Name UpArrow      -Value ($base + "Alternate.cur")
Set-ItemProperty $reg -Name Pin          -Value ($base + "Pin.cur")
Set-ItemProperty $reg -Name Person       -Value ($base + "Person.cur")

# forza refresh cursori
rundll32.exe user32.dll,UpdatePerUserSystemParameters
