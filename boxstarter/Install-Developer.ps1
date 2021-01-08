# Boxstarter Script to install developer tools, frameworks, and applications.
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

function Install-VsixPackage() {
    # Modified from https://gist.github.com/ScottHutchinson/b22339c3d3688da5c9b477281e258400
    param (
        [string]$packageName = $(throw "Please specify a Visual Studio Extension" )
    )

    $ErrorActionPreference = "Stop"

    $marketplaceHost = "https://marketplace.visualstudio.com"
    $packageUri = "$marketplaceHost/items?itemName=$packageName"
    $vsixFileName = "$Env:TEMP\$packageName.vsix"
    $vsInstallDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"

    Write-Host "Grabbing VSIX extension at $packageUri"
    $html = Invoke-WebRequest -Uri $packageUri -UseBasicParsing

    Write-Host "Attempting to download $packageName ..."
    $anchor = $html.Links | `
        Where-Object { $_.class -eq 'install-button-container' } | `
        Select-Object -ExpandProperty href

    if (-Not $anchor) {
        Write-Error "Could not find download anchor tag on the Visual Studio Extensions page"
        Exit 1
    }

    Write-Host "Anchor is $anchor"
    $href = "$marketplaceHost$anchor"
    Write-Host "Href is $href"
    Invoke-WebRequest -Uri $href -OutFile $vsixFileName -UseBasicParsing

    if (-Not (Test-Path $vsixFileName)) {
        Write-Error "Downloaded VSIX file could not be located"
        Exit 1
    }

    Write-Host "VS Install Dir is $vsInstallDir"
    Write-Host "VSIX File Name is $vsixFileName"
    Write-Host "Installing $packageName ..."
    Start-Process -Filepath "$vsInstallDir\VSIXInstaller" -ArgumentList "/q /a $vsixFileName" -Wait

    Write-Host "Cleanup..."
    Remove-Item $vsixFileName

    Write-Host "Installation of $packageName complete!"
}

#----------------------------------------------------------------------------------------------------
# Pre
#----------------------------------------------------------------------------------------------------

Disable-UAC

#----------------------------------------------------------------------------------------------------
# Enable Windows Developer Mode
#----------------------------------------------------------------------------------------------------

Write-Host "Enable Windows Developer Mode"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" -Name "AllowDevelopmentWithoutDevLicense" -Type "DWord" -Value "1"

#----------------------------------------------------------------------------------------------------
# Install additional browsers
#----------------------------------------------------------------------------------------------------

# Firefox
choco install -y "firefox" --package-parameters="/NoDesktopShortcut"

#----------------------------------------------------------------------------------------------------
# Install developer tools (part 1)
#----------------------------------------------------------------------------------------------------

# Developer fonts
choco install -y "cascadiacodepl"
choco install -y "firacode"

# Visual Studio Code
choco install -y "vscode" --package-parameters="/NoDesktopIcon"
choco install -y "vscode-settingssync"

# Devart Code Compare
# https://docs.devart.com/code-compare/
# https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
if (-not (Test-Path "$Env:ProgramFiles\Devart\Code Compare\CodeCompare.exe")) {
    Write-Host "Install Devart Code Compare"
    Invoke-WebRequest -Uri "https://www.devart.com/codecompare/codecompare.exe" -OutFile "$Env:TEMP\codecompare.exe" -UseBasicParsing
    Start-Process -Filepath "$Env:TEMP\codecompare.exe" -ArgumentList "/SILENT /NORESTART" -Wait
    Remove-Item "$Env:PUBLIC\Desktop\Code Compare.lnk" -ErrorAction "Ignore"
}

#----------------------------------------------------------------------------------------------------
# Install source control tools
#----------------------------------------------------------------------------------------------------

# Git for Windows
choco install -y "git"

# TortoiseGit
choco install -y "tortoisegit"

# GitHub Desktop
choco install -y "github-desktop"
Remove-Item "$Env:OneDrive\Desktop\GitHub Desktop.lnk" -ErrorAction "Ignore"

# Sourcetree
choco install -y "sourcetree"
Remove-Item "$Env:PUBLIC\Desktop\Sourcetree.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
# Install developer tools (part 2)
#----------------------------------------------------------------------------------------------------

# Visual Studio 2019 Core
choco install -y "visualstudio2019professional"             --package-parameters "--passive"

# Visual Studio 2019 workloads
choco install -y "visualstudio2019-workload-azure"                 --package-parameters "--passive --includeOptional" # Azure development workload
choco install -y "visualstudio2019-workload-data"                  --package-parameters "--passive --includeOptional" # Data storage and processing workload
# choco install -y "visualstudio2019-workload-datascience"           --package-parameters "--passive --includeOptional" # Data science and analytical applications workload
choco install -y "visualstudio2019-workload-manageddesktop"        --package-parameters "--passive --includeOptional" # .NET desktop develoment workload
choco install -y "visualstudio2019-workload-managedgame"           --package-parameters "--passive --includeOptional" # Game development with Unity workload
# choco install -y "visualstudio2019-workload-nativecrossplat"       --package-parameters "--passive --includeOptional" # Linux development with C++ workload
# choco install -y "visualstudio2019-workload-nativedesktop"         --package-parameters "--passive --includeOptional" # Desktop development with C++ workload
# choco install -y "visualstudio2019-workload-nativegame"            --package-parameters "--passive --includeOptional" # Game development with C++ workload
# choco install -y "visualstudio2019-workload-nativemobile"          --package-parameters "--passive --includeOptional" # Mobile development with C++ workload
choco install -y "visualstudio2019-workload-netcoretools"          --package-parameters "--passive --includeOptional" # .NET Core cross-platform development workload
# choco install -y "visualstudio2019-workload-netcrossplat"          --package-parameters "--passive --includeOptional" # Mobile development with .NET workload
choco install -y "visualstudio2019-workload-netweb"                --package-parameters "--passive --includeOptional" # ASP.NET and web development workload
# choco install -y "visualstudio2019-workload-node"                  --package-parameters "--passive --includeOptional" # Node.js development workload
# choco install -y "visualstudio2019-workload-office"                --package-parameters "--passive --includeOptional" # Office/SharePoint development workload
# choco install -y "visualstudio2019-workload-python"                --package-parameters "--passive --includeOptional" # Python development workload
choco install -y "visualstudio2019-workload-universal"             --package-parameters "--passive --includeOptional" # Universal Windows Platform development workload
# choco install -y "visualstudio2019-workload-visualstudioextension" --package-parameters "--passive --includeOptional" # Visual Studio extension development workload
Remove-Item "$Env:PUBLIC\Desktop\Unity Hub.lnk" -ErrorAction "Ignore"
RefreshEnv

# Visual Studio 2019 extensions from Microsoft
Install-VsixPackage "VisualStudioPlatformTeam.ProductivityPowerPack2017" # Productivity Power Tools
Install-VsixPackage "VisualStudioProductTeam.ProjectSystemTools"         # Project System Tools
Install-VsixPackage "azsdktm.SecurityIntelliSense-Preview"               # Security IntelliSense
Install-VsixPackage "EWoodruff.VisualStudioSpellCheckerVS2017andLater"   # Visual Studio Spell Checker (VS2017 and Later)

# Visual Studio 2019 extensions from Mads Kristensen
Install-VsixPackage "MadsKristensen.ignore"                        # .ignore
Install-VsixPackage "MadsKristensen.BrowserLinkInspector2019"      # Browser Link Inspector 2019
Install-VsixPackage "MadsKristensen.DummyTextGenerator"            # Dummy Text Generator
Install-VsixPackage "MadsKristensen.NPMTaskRunner"                 # NPM Task Runner
Install-VsixPackage "MadsKristensen.OpeninVisualStudioCode"        # Open in Visual Studio Code
Install-VsixPackage "MadsKristensen.TrailingWhitespaceVisualizer"  # Trailing Whitespace Visualizer
Install-VsixPackage "MadsKristensen.TypeScriptDefinitionGenerator" # TypeScript Definition Generator
Install-VsixPackage "MadsKristensen.WebEssentials2019"             # Web Essentials 2019

# Trust development certificates
dotnet dev-certs https --trust

#----------------------------------------------------------------------------------------------------
# Install developer utilities
#----------------------------------------------------------------------------------------------------

choco install -y "fiddler"
choco install -y "postman"
choco install -y "putty"
choco install -y "sysinternals"
choco install -y "winscp"
choco install -y "wireshark"

#----------------------------------------------------------------------------------------------------
# Install IDEs
#----------------------------------------------------------------------------------------------------

# JetBrains ReSharper Ultimate
choco install -y "resharper"

# LINQPad
choco install -y "linqpad"

#----------------------------------------------------------------------------------------------------
# Install additional frameworks & SDKs
#----------------------------------------------------------------------------------------------------

choco install -y "azure-cli"
choco install -y "make"
choco install -y "netfx-4.8-devpack"
choco install -y "dotnet-5.0-sdk"
choco install -y "nodejs"
choco install -y "nuget.commandline"

#----------------------------------------------------------------------------------------------------
# Install database tools
#----------------------------------------------------------------------------------------------------

choco install -y "azure-data-studio"
choco install -y "postgresql"
choco install -y "pgadmin4"
choco install -y "servicebusexplorer"
choco install -y "sql-server-2019"
choco install -y "sql-server-management-studio"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
