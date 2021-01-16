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
# Prompt user for theme
#----------------------------------------------------------------------------------------------------

$themes = @(
    [PSCustomObject]@{
        Name            = "Dracula"
        KeyedName       = "&Dracula"
        NotepadPlusPlus = "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/Dracula.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night"
        KeyedName       = "&Tomorrow Night"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night Bright"
        KeyedName       = "Tomorrow Night &Bright"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night_bright.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night Eighties"
        KeyedName       = "Tomorrow Night &Eighties"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night_eighties.xml"
    }
)

$options = $themes | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Name }
$theme = $themes[$host.ui.PromptForChoice("Choose theme", "What theme should be installed?", $options, 2)]

#----------------------------------------------------------------------------------------------------
# Prompt user for font
#----------------------------------------------------------------------------------------------------

$fonts = @(
    [PSCustomObject]@{
        Name              = "Cascadia Code PL"
        KeyedName         = "&Cascadia Code PL"
        ChocolateyPackage = "cascadiacodepl"
    }
    [PSCustomObject]@{
        Name              = "DejaVu"
        KeyedName         = "&DejaVu"
        ChocolateyPackage = "dejavufonts"
    }
    [PSCustomObject]@{
        Name              = "Fira Code"
        KeyedName         = "&Fira Code"
        ChocolateyPackage = "firacode" # Currently displays lots of errors, but succeeds anyway
    }
)

$options = $fonts | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Name }
$font = $fonts[$host.ui.PromptForChoice("Choose font", "What font should be installed?", $options, 2)]
$replaceFonts = ($fonts | Where-Object { $_ -NE $font } | Select-Object -ExpandProperty "Name") + @("Consolas")

#----------------------------------------------------------------------------------------------------
# Pre
#----------------------------------------------------------------------------------------------------

Disable-UAC

#----------------------------------------------------------------------------------------------------
# Configure Windows
#----------------------------------------------------------------------------------------------------

# Install fonts
$fonts | ForEach-Object {
    choco install -y $_.ChocolateyPackage
}

# Theme
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

# Search locations
Write-Host "Add Windows Search locations"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Microsoft.Search.Interop.dll" -OutFile "$Env:TEMP\Microsoft.Search.Interop.dll" -UseBasicParsing
Add-Type -Path "$Env:TEMP\Microsoft.Search.Interop.dll"
$crawlManager = (New-Object Microsoft.Search.Interop.CSearchManagerClass).GetCatalog("SystemIndex").GetCrawlScopeManager()
foreach ($location in $searchLocations) {
    $crawlManager.AddUserScopeRule("file:///$location", $true, $false, $null)
}
$crawlManager.SaveAll()

# Power & Sleep settings
Write-Host "Configure Windows Power & Battery settings"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Windows.pow" -OutFile "$Env:TEMP\Windows.pow" -UseBasicParsing
powercfg /import "$Env:TEMP\Windows.pow"

#----------------------------------------------------------------------------------------------------
# Install personal preferred utilities
#----------------------------------------------------------------------------------------------------

# Advanced Renamer
choco install -y "advanced-renamer"

# Attribute Changer
choco install -y "attributechanger"

# Divvy
choco install -y "divvy"
Remove-Item "$Env:OneDrive\Desktop\Divvy.lnk" -ErrorAction "Ignore"

# Duplicate Cleaner
choco install -y "duplicatecleaner"
Remove-Item "$Env:PUBLIC\Desktop\Duplicate Cleaner Pro.lnk" -ErrorAction "Ignore"

# Link Shell Extension
choco install -y "linkshellextension"

# Free Download Manager
choco install -y "freedownloadmanager"

#----------------------------------------------------------------------------------------------------
# Configure Notepad++
#----------------------------------------------------------------------------------------------------

# Download themes
$themes | ForEach-Object {
    Write-Host "Download '$($_.Name)' theme for Notepad++"
    $file = (Invoke-WebRequest -Uri $_.NotepadPlusPlus -UseBasicParsing).Content
    $replaceFonts | ForEach-Object {
        Write-Host "Replace ""$_.*?"" in theme file with ""$($font.Name)"""
        [regex]::Matches($file, """$_.*?""") | ForEach-Object { $file = $file.Replace($_, """$($font.Name)""") }
    }
    $file | Out-File -FilePath "$Env:APPDATA\Notepad++\themes\$($_.Name).xml" -Encoding "windows-1252" -Force -NoNewline
}

# Delete any pre-existing configuration
Write-Host "Delete existing configuration for Notepad++, if any"
Remove-Item "$Env:APPDATA\Notepad++\config.xml" -ErrorAction "Ignore"

# Download configuration
Write-Host "Download configuration for Notepad++"
$file = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Notepad++.xml" -UseBasicParsing).Content
[regex]::Matches($file, "%\w+%") | ForEach-Object { $file = $file.Replace($_, [System.Environment]::ExpandEnvironmentVariables($_)) }
[regex]::Matches($file, "«theme»") | ForEach-Object { $file = $file.Replace($_, $theme.Name) }
$file | Out-File -FilePath "$Env:APPDATA\Notepad++\config.xml" -Encoding "windows-1252" -Force -NoNewline

# Download LuaScript page
Write-Host "Scrape webpage for latest version of LuaScript plugin for Notepad++"
$response = Invoke-WebRequest -Uri "https://github.com/dail8859/LuaScript/releases/latest" -UseBasicParsing
$anchor = $response.Links | Where-Object { $_.href -match "LuaScript_v.*?_x64.zip" } | Select-Object -ExpandProperty "href"
$packageUri = "https://github.com$anchor"
Write-Host "Download LuaScript plugin for Notepad++ from $packageUri"
$file = $packageUri.Substring($packageUri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $packageUri -OutFile "$Env:TEMP\$file" -UseBasicParsing
Write-Host "Unzip LuaScript plugin for Notepad++"
Expand-Archive -LiteralPath "$Env:TEMP\$file" -DestinationPath "$Env:ProgramFiles\Notepad++\plugins\LuaScript\"

# Set startup Lua script
Write-Host "Configure startup script for Notepad++"
@"
-- Startup script
-- Changes will take effect once Notepad++ is restarted

editor1.Technology = SC_TECHNOLOGY_DIRECTWRITE
editor2.Technology = SC_TECHNOLOGY_DIRECTWRITE
"@ | Out-File -FilePath "$Env:APPDATA\Notepad++\plugins\config\startup.lua" -Encoding "windows-1252" -Force

#----------------------------------------------------------------------------------------------------
# Configure source control tools
#----------------------------------------------------------------------------------------------------

# Git
Write-Host "Configure Git"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/.gitconfig"     -OutFile "$Env:USERPROFILE\.gitconfig"     -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/.gitconfig-rj"  -OutFile "$Env:USERPROFILE\.gitconfig-rj"  -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/.gitconfig-wtw" -OutFile "$Env:USERPROFILE\.gitconfig-wtw" -UseBasicParsing

# Bash
Write-Host "Configure Bash shell"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/.bashrc"       -OutFile "$Env:USERPROFILE\.bashrc"       -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/.bash_profile" -OutFile "$Env:USERPROFILE\.bash_profile" -UseBasicParsing

# TortoiseGit
Write-Host "Configure TortoiseGit"
Push-Location -Path "HKCU:\Software\"; & {
    Push-Location -Path ".\TortoiseGit\"; & {
        Set-ItemProperty -Path "." -Name "DarkTheme"               -Type "DWord"  -Value "1"
        Set-ItemProperty -Path "." -Name "Diff"                    -Type "String" -Value """C:\Program Files\Devart\Code Compare\CodeCompare.exe"" /SC=TortoiseGit /T1=%bname /T2=%yname %base %mine"
        Set-ItemProperty -Path "." -Name "Merge"                   -Type "String" -Value """C:\Program Files\Devart\Code Compare\CodeMerge.exe"" /SC=TortoiseGit /BF=%base /BT=%bname /TF=%theirs /TT=%tname /MF=%mine /MT=%yname /RF=%merged /RT=%mname /REMOVEFILES"
        Set-ItemProperty -Path "." -Name "MergeBlockTrustBehavior" -Type "DWord"  -Value "2"

        if (-Not (Test-Path ".\Colors\")) { New-Item -Path ".\Colors\" }
        Push-Location -Path ".\Colors\"; & {
            Set-ItemProperty -Path "." -Name "NoteNode" -Type "DWord" -Value "16776960"
        }; Pop-Location
    }; Pop-Location

    $overlayFolder = "$Env:CommonProgramFiles\TortoiseOverlays\Icons\Win10"
    if (-Not (Test-Path ".\TortoiseOverlays\")) { New-Item -Path ".\TortoiseOverlays\" }
    Push-Location -Path ".\TortoiseOverlays\"; & {
        Set-ItemProperty -Path "." -Name "AddedIcon"       -Type "String" -Value "$overlayFolder\AddedIcon.ico"
        Set-ItemProperty -Path "." -Name "ConflictIcon"    -Type "String" -Value "$overlayFolder\ConflictIcon.ico"
        Set-ItemProperty -Path "." -Name "DeletedIcon"     -Type "String" -Value "$overlayFolder\DeletedIcon.ico"
        Set-ItemProperty -Path "." -Name "IgnoredIcon"     -Type "String" -Value "$overlayFolder\IgnoredIcon.ico"
        Set-ItemProperty -Path "." -Name "LockedIcon"      -Type "String" -Value "$overlayFolder\LockedIcon.ico"
        Set-ItemProperty -Path "." -Name "ModifiedIcon"    -Type "String" -Value "$overlayFolder\ModifiedIcon.ico"
        Set-ItemProperty -Path "." -Name "NormalIcon"      -Type "String" -Value "$overlayFolder\NormalIcon.ico"
        Set-ItemProperty -Path "." -Name "ReadOnlyIcon"    -Type "String" -Value "$overlayFolder\ReadOnlyIcon.ico"
        Set-ItemProperty -Path "." -Name "UnversionedIcon" -Type "String" -Value "$overlayFolder\UnversionedIcon.ico"
    }; Pop-Location
}; Pop-Location

#----------------------------------------------------------------------------------------------------
# Configure other applications
#----------------------------------------------------------------------------------------------------

# Visual Studio 2019
Write-Host "Configure Visual Studio 2019"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/VisualStudio.vssettings" -OutFile "$Env:TEMP\VisualStudio.vssettings" -UseBasicParsing
devenv /ResetSettings "$Env:TEMP\VisualStudio.vssettings"

# TODO: Figure out how to import the '..\apps\CodeCompare.settings' file into Code Compare via command line
Write-Host "Configure Code Compare"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/CodeCompare.settings" -OutFile "$Env:OneDrive\CodeCompare.settings"  -UseBasicParsing

# LINQPad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/LINQPad.xml" -OutFile "$Env:APPDATA\LINQPad\RoamingUserOptions.xml" -UseBasicParsing

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
