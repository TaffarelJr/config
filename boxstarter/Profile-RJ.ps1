# Boxstarter Script to apply RJ's personal user profile configuration and install preferred applications.
# https://boxstarter.org/
#
# Install Boxstarter:
# 	. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# Set: Set-ExecutionPolicy RemoteSigned
# Then: Install-BoxstarterPackage -PackageName <URL-TO-RAW-OR-GIST> -DisableReboots
#
# Pulled from samples by:
# - Microsoft https://github.com/Microsoft/windows-dev-box-setup-scripts
# - elithrar https://github.com/elithrar/dotfiles
# - ElJefeDSecurIT https://gist.github.com/ElJefeDSecurIT/014fcfb87a7372d64934995b5f09683e
# - jessfraz https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# - NickCraver https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

$purpleShadowDark_AccentColorMenu = "0xffd6696b"
$purpleShadowDark_StartColorMenu = "0xff9e4d4f"
$purpleShadowDark_accentPalette = [byte[]]@(`
        "0xd5", "0xd4", "0xff", "0x00", "0xad", "0xac", "0xf0", "0x00", `
        "0x89", "0x87", "0xe4", "0x00", "0x6b", "0x69", "0xd6", "0x00", `
        "0x4f", "0x4d", "0x9e", "0x00", "0x2d", "0x2b", "0x61", "0x00", `
        "0x1f", "0x1f", "0x4d", "0x00", "0x00", "0xcc", "0x6a", "0x00"
)

$searchLocations = @(
    "C:\Code"
)

#----------------------------------------------------------------------------------------------------
# Pre
#----------------------------------------------------------------------------------------------------

Disable-UAC

#----------------------------------------------------------------------------------------------------
# Configure Windows Theme
#----------------------------------------------------------------------------------------------------

Write-Host "Configure Windows theme"
Push-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\"; & {
    Push-Location -Path ".\Themes\Personalize\"; & {
        Set-ItemProperty -Path "." -Name "AppsUseLightTheme"    -Type "DWord" -Value "0"
        Set-ItemProperty -Path "." -Name "SystemUsesLightTheme" -Type "DWord" -Value "0"
    }; Pop-Location

    Push-Location -Path ".\Explorer\Accent\"; & {
        Set-ItemProperty -Path "." -Name "AccentColorMenu" -Type "DWord"  -Value $purpleShadowDark_AccentColorMenu
        Set-ItemProperty -Path "." -Name "AccentPalette"   -Type "Binary" -Value $purpleShadowDark_accentPalette
        Set-ItemProperty -Path "." -Name "StartColorMenu"  -Type "DWord"  -Value $purpleShadowDark_StartColorMenu
    }; Pop-Location
}; Pop-Location

#----------------------------------------------------------------------------------------------------
# Configure Windows Search locations
#----------------------------------------------------------------------------------------------------

Write-Host "Add Windows Search locations"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Microsoft.Search.Interop.dll" -OutFile ".\Microsoft.Search.Interop.dll"
Add-Type -Path ".\Microsoft.Search.Interop.dll"
$crawlManager = (New-Object Microsoft.Search.Interop.CSearchManagerClass).GetCatalog("SystemIndex").GetCrawlScopeManager()

foreach ($location in $searchLocations) {
    $crawlManager.AddUserScopeRule("file:///$location", $true, $false, $null)
}

$crawlManager.SaveAll()

#----------------------------------------------------------------------------------------------------
# Install personal utilities
#----------------------------------------------------------------------------------------------------

# Attribute Changer
choco install -y "attributechanger"

# Link Shell Extension
choco install -y "linkshellextension"

# Advanced Renamer
choco install -y "advanced-renamer"

# Duplicate Cleaner
choco install -y "duplicatecleaner"
Remove-Item "$Env:PUBLIC\Desktop\Duplicate Cleaner Pro.lnk" -ErrorAction "Ignore"

# Free Download Manager
choco install -y "freedownloadmanager"

# Divvy
choco install -y "divvy"
Remove-Item "$Env:OneDrive\Desktop\Divvy.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
# Configure applications
#----------------------------------------------------------------------------------------------------

# Windows Power & Sleep settings
Write-Host "Set Windows Power & battery configuration"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Windows.pow" -OutFile "$Env:TEMP\Windows.pow"
powercfg /import "$Env:TEMP\Windows.pow"

# Notepad++
Write-Host "Set Notepad++ configuration"
$file = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Notepad++.xml").Content
[regex]::Matches($file, "%\w+%") | ForEach-Object { $file = $file.Replace($_, [System.Environment]::ExpandEnvironmentVariables($_)) }
$file | Out-File "$Env:APPDATA\Notepad++\config.xml"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
