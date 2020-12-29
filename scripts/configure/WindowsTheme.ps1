# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

$startColorMenu_PurpleShadowDark = "0xff9e4d4f"
$accentColorMenu_PurpleShadowDark = "0xffd6696b"
$accentPalette_PurpleShadowDark = [byte[]]@(`
        "0xd5", "0xd4", "0xff", "0x00", "0xad", "0xac", "0xf0", "0x00", `
        "0x89", "0x87", "0xe4", "0x00", "0x6b", "0x69", "0xd6", "0x00", `
        "0x4f", "0x4d", "0x9e", "0x00", "0x2d", "0x2b", "0x61", "0x00", `
        "0x1f", "0x1f", "0x4d", "0x00", "0x00", "0xcc", "0x6a", "0x00"
)

Write-Header "Configure Windows theme"

Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\"
& {
    Push-Location -Path ".\Themes\Personalize\"
    & {
        Write-Host (Add-Indent "Apply dark theme to Windows")
        Set-ItemProperty -Path "." -Name "SystemUsesLightTheme" -Type "DWord" -Value "0"

        Write-Host (Add-Indent "Apply dark theme to applications")
        Set-ItemProperty -Path "." -Name "AppsUseLightTheme" -Type "DWord" -Value "0"
    }
    Pop-Location

    Push-Location -Path ".\Explorer\Accent\"
    & {
        Write-Host (Add-Indent "Set Windows accent color")
        Set-ItemProperty -Path "." -Name "AccentColorMenu" -Type "DWord" -Value $accentColorMenu_PurpleShadowDark

        Write-Host (Add-Indent "Set Windows accent palette")
        Set-ItemProperty -Path "." -Name "AccentPalette" -Type "Binary" -Value $accentPalette_PurpleShadowDark

        Write-Host (Add-Indent "Set Windows start color")
        Set-ItemProperty -Path "." -Name "StartColorMenu" -Type "DWord" -Value $startColorMenu_PurpleShadowDark
    }
    Pop-Location
}
Pop-Location
