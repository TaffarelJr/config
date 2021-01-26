#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$repoUri = "https://raw.githubusercontent.com/TaffarelJr/config/test"
$fileUri = "$repoUri/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $fileUri"
Invoke-WebRequest -Uri $fileUri -OutFile $filePath -UseBasicParsing
. $filePath

#----------------------------------------------------------------------------------------------------
Write-Header "Add custom locations to Windows Search"
#----------------------------------------------------------------------------------------------------

Write-Host "Download interop library"
$interopFile = "$Env:TEMP\Microsoft.Search.Interop.dll"
Invoke-WebRequest -Uri "$repoUri/boxstarter/Microsoft.Search.Interop.dll" -OutFile $interopFile -UseBasicParsing
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

Invoke-WebRequest -Uri "$repoUri/apps/Windows.pow" -OutFile "$Env:TEMP\Windows.pow" -UseBasicParsing
powercfg /import "$Env:TEMP\Windows.pow"

#----------------------------------------------------------------------------------------------------
Write-Header "Install developer fonts"
#----------------------------------------------------------------------------------------------------

$fonts = @(
    @{
        Name              = "Cascadia Code PL"
        KeyedName         = "&Cascadia Code PL"
        ChocolateyPackage = "cascadiacodepl"
    }
    @{
        Name              = "DejaVu"
        KeyedName         = "&DejaVu"
        ChocolateyPackage = "dejavufonts"
    }
    @{
        Name              = "Fira Code"
        KeyedName         = "&Fira Code"
        ChocolateyPackage = "firacode" # Currently displays lots of errors, but succeeds anyway
    }
    @{
        Name              = "Hack"
        KeyedName         = "&Hack"
        ChocolateyPackage = "hackfont"
    }
)

# Install all fonts
$fonts | ForEach-Object { choco install -y $chocoCache $_.ChocolateyPackage }

# Prompt user to choose a specific font
$options = $fonts | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Name }
$font = $fonts[$host.ui.PromptForChoice("Choose Font", "Select a developer font:", $options, 2)].Name

#----------------------------------------------------------------------------------------------------
Write-Header "Install developer themes"
#----------------------------------------------------------------------------------------------------

$themes = @(
    @{
        KeyedName = "&Dracula"
        Base16Uri = "$repoUri/themes/Dracula.yml"
    }
    @{
        KeyedName = "&Tomorrow Night"
        Base16Uri = "$repoUri/themes/TomorrowNight.yml"
    }
    @{
        KeyedName = "Tomorrow Night &Bright"
        Base16Uri = "$repoUri/themes/TomorrowNight-Bright.yml"
    }
    @{
        KeyedName = "Tomorrow Night &Eighties"
        Base16Uri = "$repoUri/themes/TomorrowNight-Eighties.yml"
    }
) | Import-Theme

# Add the selected developer font to each theme
$themes | ForEach-Object { $_["Font"] = $font }

# Prompt user to choose a specific theme
$options = $themes | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_.KeyedName, $_.Scheme }
$theme = $themes[$host.ui.PromptForChoice("Choose Theme", "Select a developer theme:", $options, 2)]

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Windows Theme"
#----------------------------------------------------------------------------------------------------

# Purple Shadow Dark theme
$accentColorMenu = "0xffd6696b"
$startColorMenu = "0xff9e4d4f"
$accentPalette = [byte[]]@(`
        "0xd5", "0xd4", "0xff", "0x00", "0xad", "0xac", "0xf0", "0x00", `
        "0x89", "0x87", "0xe4", "0x00", "0x6b", "0x69", "0xd6", "0x00", `
        "0x4f", "0x4d", "0x9e", "0x00", "0x2d", "0x2b", "0x61", "0x00", `
        "0x1f", "0x1f", "0x4d", "0x00", "0x00", "0xcc", "0x6a", "0x00"
)

Enter-Location -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\" {
    Enter-Location -Path ".\Themes\Personalize\" {
        Set-ItemProperty -Path "." -Name "AppsUseLightTheme"    -Type "DWord" -Value 0
        Set-ItemProperty -Path "." -Name "SystemUsesLightTheme" -Type "DWord" -Value 0
    }

    Enter-Location -Path ".\Explorer\Accent\" {
        Set-ItemProperty -Path "." -Name "AccentColorMenu" -Type "DWord"  -Value $accentColorMenu
        Set-ItemProperty -Path "." -Name "AccentPalette"   -Type "Binary" -Value $accentPalette
        Set-ItemProperty -Path "." -Name "StartColorMenu"  -Type "DWord"  -Value $startColorMenu
    }
}

#----------------------------------------------------------------------------------------------------
Write-Header "Install personal utilities"
#----------------------------------------------------------------------------------------------------

# Advanced Renamer
choco install -y $chocoCache "advanced-renamer"

# Attribute Changer
choco install -y $chocoCache "attributechanger"

# Divvy
choco install -y $chocoCache "divvy"
Remove-Item "$Env:OneDrive\Desktop\Divvy.lnk" -ErrorAction "Ignore"

# Duplicate Cleaner
choco install -y $chocoCache "duplicatecleaner"
Remove-Item "$Env:PUBLIC\Desktop\Duplicate Cleaner Pro.lnk" -ErrorAction "Ignore"

# Free Download Manager
choco install -y $chocoCache "freedownloadmanager"

# Link Shell Extension
choco install -y $chocoCache "linkshellextension"

#----------------------------------------------------------------------------------------------------
Write-Header "Configure Notepad++"
#----------------------------------------------------------------------------------------------------

# Download themes
$template = (Invoke-WebRequest -Uri "$repoUri/apps/Notepad++Theme.xml" -UseBasicParsing).Content
$themes | ForEach-Object {
    Write-Host "Install '$($_.Scheme)' theme into Notepad++"
    $file = Expand-TemplateString -String $template -Values $_
    [IO.File]::WriteAllLines("$Env:APPDATA\Notepad++\themes\$($_.Scheme).xml", $file, [System.Text.Encoding]::GetEncoding(1252))
}

# Download configuration
Write-Host "Download configuration"
$template = (Invoke-WebRequest -Uri "$repoUri/apps/Notepad++.xml" -UseBasicParsing).Content
$file = Expand-TemplateString -String $template -Values $theme
[IO.File]::WriteAllLines("$Env:APPDATA\Notepad++\config.xml", $file, [System.Text.Encoding]::GetEncoding(1252))

# Scrape LuaScript page for download link
Write-Host "Scrape webpage for latest version of LuaScript plugin"
$response = Invoke-WebRequest -Uri "https://github.com/dail8859/LuaScript/releases/latest" -UseBasicParsing
$anchor = $response.Links | Where-Object { $_.href -match "LuaScript_v.*?_x64.zip" } | Select-Object -ExpandProperty "href"
$packageUri = "https://github.com$anchor"

# Download LuaScript plugin
Write-Host "Download LuaScript plugin from $packageUri"
$tempFilePath = "$Env:TEMP\$($packageUri.Substring($packageUri.LastIndexOf("/") + 1))"
Invoke-WebRequest -Uri $packageUri -OutFile $tempFilePath -UseBasicParsing

# Install LuaScript plugin
Write-Host "Install LuaScript plugin"
Expand-Archive -LiteralPath $tempFilePath -DestinationPath "$Env:ProgramFiles\Notepad++\plugins\LuaScript\" -Force

# Set startup Lua script
Write-Host "Configure startup script"
$file = @"
-- Startup script
-- Changes will take effect once Notepad++ is restarted

editor1.Technology = SC_TECHNOLOGY_DIRECTWRITE
editor2.Technology = SC_TECHNOLOGY_DIRECTWRITE
"@
[IO.File]::WriteAllLines("$Env:APPDATA\Notepad++\plugins\config\startup.lua", $file, [System.Text.Encoding]::GetEncoding(1252))

#----------------------------------------------------------------------------------------------------
Write-Header "Configure source control tools"
#----------------------------------------------------------------------------------------------------

# Git
Write-Host "Configure Git"
Invoke-WebRequest -Uri "$repoUri/apps/.gitconfig"     -OutFile "$Env:USERPROFILE\.gitconfig"     -UseBasicParsing
Invoke-WebRequest -Uri "$repoUri/apps/.gitconfig-rj"  -OutFile "$Env:USERPROFILE\.gitconfig-rj"  -UseBasicParsing
Invoke-WebRequest -Uri "$repoUri/apps/.gitconfig-wtw" -OutFile "$Env:USERPROFILE\.gitconfig-wtw" -UseBasicParsing

# Bash
Write-Host "Configure Bash shell"
Invoke-WebRequest -Uri "$repoUri/apps/.bashrc"       -OutFile "$Env:USERPROFILE\.bashrc"       -UseBasicParsing
Invoke-WebRequest -Uri "$repoUri/apps/.bash_profile" -OutFile "$Env:USERPROFILE\.bash_profile" -UseBasicParsing

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
    Invoke-WebRequest -Uri "$repoUri/apps/VisualStudio.xml" -OutFile "$Env:TEMP\VisualStudio.vssettings" -UseBasicParsing

    # Import configuration settings
    devenv /ResetSettings "$Env:TEMP\VisualStudio.vssettings"
}

#----------------------------------------------------------------------------------------------------
Write-Header "Configure other applications"
#----------------------------------------------------------------------------------------------------

# TODO: Figure out how to import the '..\apps\CodeCompare.xml' file into Code Compare via command line
Write-Host "Configure Code Compare"
Invoke-WebRequest -Uri "$repoUri/apps/CodeCompare.xml" -OutFile "$Env:OneDrive\CodeCompare.settings"  -UseBasicParsing

# LINQPad
Invoke-WebRequest -Uri "$repoUri/apps/LINQPad.xml" -OutFile "$Env:APPDATA\LINQPad\RoamingUserOptions.xml" -UseBasicParsing

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
