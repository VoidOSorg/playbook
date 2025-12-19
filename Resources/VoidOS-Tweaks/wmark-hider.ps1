Set-ExecutionPolicy Unrestricted -Scope CurrentUser


Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name PaintDesktopVersion
