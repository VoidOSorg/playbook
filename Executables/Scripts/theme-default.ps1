$Hive = "Registry::HKU\VOID_Default"

# Dark mode
Set-ItemProperty "$Hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
  SystemUsesLightTheme 0 -Type DWord

Set-ItemProperty "$Hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
  AppsUseLightTheme 0 -Type DWord

# No transparency
Set-ItemProperty "$Hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
  EnableTransparency 0 -Type DWord

# Best performance (NO animations, peek, shadows)
Set-ItemProperty "$Hive\Control Panel\Desktop" `
  UserPreferencesMask ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

# Wallpaper (default user)
Set-ItemProperty "$Hive\Control Panel\Desktop" `
  Wallpaper "C:\Windows\VoidOS\wllppr0.png"
