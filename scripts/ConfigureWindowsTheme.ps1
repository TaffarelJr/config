# Load supporting script files
. ".\Utilities.ps1"

$accentPalette = [byte[]]@(`
		"0xd5", "0xd4", "0xff", "0x00", "0xad", "0xac", "0xf0", "0x00", `
		"0x89", "0x87", "0xe4", "0x00", "0x6b", "0x69", "0xd6", "0x00", `
		"0x4f", "0x4d", "0x9e", "0x00", "0x2d", "0x2b", "0x61", "0x00", `
		"0x1f", "0x1f", "0x4d", "0x00", "0x00", "0xcc", "0x6a", "0x00"
)

Write-Header "Configure Windows theme"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\"

Push-Location -Path ".\Themes\Personalize\"
Write-Host (Add-Indent "Applying Windows dark theme ...")
Set-ItemProperty -Path "." -Name "AppsUseLightTheme" -Type "DWord" -Value "0"
Set-ItemProperty -Path "." -Name "SystemUsesLightTheme" -Type "DWord" -Value "0"
Pop-Location

Push-Location -Path ".\Explorer\Accent\"
Write-Host (Add-Indent "Setting Windows accent color ...")
Set-ItemProperty -Path "." -Name "AccentColorMenu" -Type "DWord" -Value "0xffd6696b"
Set-ItemProperty -Path "." -Name "AccentPalette" -Type "Binary" -Value $accentPalette
Set-ItemProperty -Path "." -Name "StartColorMenu" -Type "DWord" -Value "0xff9e4d4f"
Pop-Location

Pop-Location
Write-Host "Done"
