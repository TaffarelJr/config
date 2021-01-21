$purpleShadowDark_AccentColorMenu = "0xffd6696b"
$purpleShadowDark_StartColorMenu = "0xff9e4d4f"
$purpleShadowDark_accentPalette = [byte[]]@(`
        "0xd5", "0xd4", "0xff", "0x00", "0xad", "0xac", "0xf0", "0x00", `
        "0x89", "0x87", "0xe4", "0x00", "0x6b", "0x69", "0xd6", "0x00", `
        "0x4f", "0x4d", "0x9e", "0x00", "0x2d", "0x2b", "0x61", "0x00", `
        "0x1f", "0x1f", "0x4d", "0x00", "0x00", "0xcc", "0x6a", "0x00"
)

#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$uri = "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $uri"
Invoke-WebRequest -Uri $uri -OutFile $filePath -UseBasicParsing
. $filePath

#----------------------------------------------------------------------------------------------------
Write-Header "Choose theme"
#----------------------------------------------------------------------------------------------------

$themes = @(
    [PSCustomObject]@{
        Name            = "Dracula"
        KeyedName       = "&Dracula"
        Base16          = "https://raw.githubusercontent.com/dracula/base16-dracula-scheme/master/dracula.yaml"
        NotepadPlusPlus = "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/Dracula.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night"
        KeyedName       = "&Tomorrow Night"
        Base16          = "https://raw.githubusercontent.com/chriskempson/base16-tomorrow-scheme/master/tomorrow-night.yaml"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night Bright"
        KeyedName       = "Tomorrow Night &Bright"
        Base16          = "https://raw.githubusercontent.com/Tyilo/base16-tomorrow-scheme/night-bright/tomorrow-night-bright.yaml"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night_bright.xml"
    }
    [PSCustomObject]@{
        Name            = "Tomorrow Night Eighties"
        KeyedName       = "Tomorrow Night &Eighties"
        Base16          = "https://raw.githubusercontent.com/chriskempson/base16-tomorrow-scheme/master/tomorrow-night-eighties.yaml"
        NotepadPlusPlus = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/notepad%2B%2B/tomorrow_night_eighties.xml"
    }
)

# Prompt user
$options = $themes | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Name }
$theme = $themes[$host.ui.PromptForChoice("Choose theme", "What theme should be installed?", $options, 2)]

# Load Base16 pallete for selected theme
$theme.Base16 = ConvertFrom-Yaml (Invoke-WebRequest -Uri $theme.Base16 -UseBasicParsing).Content

#----------------------------------------------------------------------------------------------------
Write-Header "Choose developer font"
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

# Prompt user
$options = $fonts | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Name }
$font = $fonts[$host.ui.PromptForChoice("Choose font", "What font should be installed?", $options, 2)]
$replaceFonts = ($fonts | Where-Object { $_ -NE $font } | Select-Object -ExpandProperty "Name") + @("Consolas")

#----------------------------------------------------------------------------------------------------
Write-Header "Install developer fonts"
#----------------------------------------------------------------------------------------------------

$fonts | ForEach-Object {
    choco install -y $_.ChocolateyPackage
}

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Windows Theme"
#----------------------------------------------------------------------------------------------------

Enter-Location -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\" {
    Enter-Location -Path ".\Themes\Personalize\" {
        Set-ItemProperty -Path "." -Name "AppsUseLightTheme"    -Type "DWord" -Value 0
        Set-ItemProperty -Path "." -Name "SystemUsesLightTheme" -Type "DWord" -Value 0
    }

    Enter-Location -Path ".\Explorer\Accent\" {
        Set-ItemProperty -Path "." -Name "AccentColorMenu" -Type "DWord"  -Value $purpleShadowDark_AccentColorMenu
        Set-ItemProperty -Path "." -Name "AccentPalette"   -Type "Binary" -Value $purpleShadowDark_accentPalette
        Set-ItemProperty -Path "." -Name "StartColorMenu"  -Type "DWord"  -Value $purpleShadowDark_StartColorMenu
    }
}

#----------------------------------------------------------------------------------------------------
Write-Header "Add custom locations to Windows Search"
#----------------------------------------------------------------------------------------------------

Write-Host "Download interop library"
$interopFile = "$Env:TEMP\Microsoft.Search.Interop.dll"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Microsoft.Search.Interop.dll" -OutFile $interopFile -UseBasicParsing
Add-Type -Path $interopFile
$crawlManager = (New-Object Microsoft.Search.Interop.CSearchManagerClass).GetCatalog("SystemIndex").GetCrawlScopeManager()

Write-host "Add search locations"
@(
    "C:\Code"
) | ForEach-Object {
    Write-host "    $_"
    $crawlManager.AddUserScopeRule("file:///$_", $true, $false, $null)
}

$crawlManager.SaveAll()

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Power & Sleep settings"
#----------------------------------------------------------------------------------------------------

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Windows.pow" -OutFile "$Env:TEMP\Windows.pow" -UseBasicParsing
powercfg /import "$Env:TEMP\Windows.pow"

#----------------------------------------------------------------------------------------------------
Write-Header "Install personal utilities"
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
Write-Header "Configure Notepad++"
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
Write-Header "Configure source control tools"
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
Enter-Location -Path "HKCU:\SOFTWARE\" {
    if (Test-Path ".\TortoiseGit\") {
        Enter-Location -Path ".\TortoiseGit\" {
            Set-ItemProperty -Path "." -Name "DarkTheme"               -Type "DWord"  -Value "1"
            Set-ItemProperty -Path "." -Name "Diff"                    -Type "String" -Value """C:\Program Files\Devart\Code Compare\CodeCompare.exe"" /SC=TortoiseGit /T1=%bname /T2=%yname %base %mine"
            Set-ItemProperty -Path "." -Name "Merge"                   -Type "String" -Value """C:\Program Files\Devart\Code Compare\CodeMerge.exe"" /SC=TortoiseGit /BF=%base /BT=%bname /TF=%theirs /TT=%tname /MF=%mine /MT=%yname /RF=%merged /RT=%mname /REMOVEFILES"
            Set-ItemProperty -Path "." -Name "MergeBlockTrustBehavior" -Type "DWord"  -Value "2"

            if (-Not (Test-Path ".\Colors\")) { New-Item -Path ".\Colors\" }
            Enter-Location -Path ".\Colors\" {
                Set-ItemProperty -Path "." -Name "NoteNode" -Type "DWord" -Value "16776960"
            }
        }

        $overlayFolder = "$Env:CommonProgramFiles\TortoiseOverlays\Icons\Win10"
        if (-Not (Test-Path ".\TortoiseOverlays\")) { New-Item -Path ".\TortoiseOverlays\" }
        Enter-Location -Path ".\TortoiseOverlays\" {
            Set-ItemProperty -Path "." -Name "AddedIcon"       -Type "String" -Value "$overlayFolder\AddedIcon.ico"
            Set-ItemProperty -Path "." -Name "ConflictIcon"    -Type "String" -Value "$overlayFolder\ConflictIcon.ico"
            Set-ItemProperty -Path "." -Name "DeletedIcon"     -Type "String" -Value "$overlayFolder\DeletedIcon.ico"
            Set-ItemProperty -Path "." -Name "IgnoredIcon"     -Type "String" -Value "$overlayFolder\IgnoredIcon.ico"
            Set-ItemProperty -Path "." -Name "LockedIcon"      -Type "String" -Value "$overlayFolder\LockedIcon.ico"
            Set-ItemProperty -Path "." -Name "ModifiedIcon"    -Type "String" -Value "$overlayFolder\ModifiedIcon.ico"
            Set-ItemProperty -Path "." -Name "NormalIcon"      -Type "String" -Value "$overlayFolder\NormalIcon.ico"
            Set-ItemProperty -Path "." -Name "ReadOnlyIcon"    -Type "String" -Value "$overlayFolder\ReadOnlyIcon.ico"
            Set-ItemProperty -Path "." -Name "UnversionedIcon" -Type "String" -Value "$overlayFolder\UnversionedIcon.ico"
        }
    }
}

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Visual Studio 2019"
#----------------------------------------------------------------------------------------------------

# Check if Visual Studio is installed
$devShell = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
if (Test-Path $devShell) {
    # Load the Visual Studio Developer Console commands
    Import-Module $devShell
    Enter-VsDevShell "ccbcf63a"

    # Download configuration settings
    Write-Host "Configure Visual Studio 2019"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/VisualStudio.xml" -OutFile "$Env:TEMP\VisualStudio.vssettings" -UseBasicParsing

    # Import configuration settings
    devenv /ResetSettings "$Env:TEMP\VisualStudio.vssettings"
}

#----------------------------------------------------------------------------------------------------
Write-Header "Configure other applications"
#----------------------------------------------------------------------------------------------------

# TODO: Figure out how to import the '..\apps\CodeCompare.xml' file into Code Compare via command line
Write-Host "Configure Code Compare"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/CodeCompare.xml" -OutFile "$Env:OneDrive\CodeCompare.settings"  -UseBasicParsing

# LINQPad
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/LINQPad.xml" -OutFile "$Env:APPDATA\LINQPad\RoamingUserOptions.xml" -UseBasicParsing

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
