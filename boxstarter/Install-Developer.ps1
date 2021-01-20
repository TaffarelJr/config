$vsInstallDir = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE"
$marketplace = "https://marketplace.visualstudio.com"

function Install-VsixPackage() {
    # Modified from https://gist.github.com/ScottHutchinson/b22339c3d3688da5c9b477281e258400
    param (
        [string]$packageName = $(throw "Please specify a Visual Studio Extension" )
    )

    $ErrorActionPreference = "Stop"

    $packagePage = "$marketplace/items?itemName=$packageName"
    Write-Host "Scrape VSIX details from $packagePage"
    $response = Invoke-WebRequest -Uri $packagePage -UseBasicParsing
    $anchor = $response.Links | Where-Object { $_.class -eq "install-button-container" } | Select-Object -ExpandProperty "href"
    if (-Not $anchor) {
        Write-Error "Could not find download anchor tag on the Visual Studio Extensions page"
        exit 1
    }
    $vsixId = $response.Content | Select-String -List -Pattern '"VsixId":"(.+?)"' | ForEach-Object { $_.Matches.Groups[1].Value }
    if (-Not $vsixId) {
        Write-Error "Could not find VSIX ID on the Visual Studio Extensions page"
        exit 1
    }

    if ($installedVsExtensions -Contains $vsixId) {
        Write-Host "Already installed. Skipping"
    }
    else {
        $packageUri = "$marketplace$anchor"
        $vsixFileName = "$Env:TEMP\$packageName.vsix"
        Write-Host "Attempting to download $packageUri ..."
        Invoke-WebRequest -Uri $packageUri -OutFile $vsixFileName -UseBasicParsing -Headers @{
            "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
            "accept-encoding"           = "gzip, deflate, br"
            "accept-language"           = "en-US,en;q=0.9"
            "dnt"                       = "1"
            "sec-fetch-dest"            = "document"
            "sec-fetch-mode"            = "navigate"
            "sec-fetch-site"            = "same-origin"
            "sec-fetch-user"            = "?1"
            "upgrade-insecure-requests" = "1"
            "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36"
        }
        if (-Not (Test-Path $vsixFileName)) {
            Write-Error "Downloaded VSIX file could not be located"
            exit 1
        }

        Write-Host "Installing $vsixFileName ..."
        Start-Process -Filepath "$vsInstallDir\VSIXInstaller.exe" -ArgumentList "/quiet /admin '$vsixFileName'" -Wait
        Remove-Item $vsixFileName
        Write-Host "Installation of $packageName complete!"
    }
}

#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$uri = "https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $uri ..." -NoNewline
Invoke-WebRequest -Uri $uri -OutFile $filePath -UseBasicParsing
. $filePath
Write-Host "Done"

Disable-UAC

#----------------------------------------------------------------------------------------------------
Write-Header "Enable Windows Developer Mode"
#----------------------------------------------------------------------------------------------------

Write-Host "Enable Windows Developer Mode"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" -Name "AllowDevelopmentWithoutDevLicense" -Type "DWord" -Value "1"

#----------------------------------------------------------------------------------------------------
Write-Header "Install additional browsers"
#----------------------------------------------------------------------------------------------------

# Firefox
choco install -y "firefox" --package-parameters="/NoDesktopShortcut"

#----------------------------------------------------------------------------------------------------
Write-Header "Install source control tools"
#----------------------------------------------------------------------------------------------------

# Git for Windows
choco install -y "git"
RefreshEnv

# TortoiseGit
choco install -y "tortoisegit"
RefreshEnv

# GitHub Desktop
choco install -y "github-desktop"
Remove-Item "$Env:OneDrive\Desktop\GitHub Desktop.lnk" -ErrorAction "Ignore"
RefreshEnv

# Sourcetree
choco install -y "sourcetree"
Remove-Item "$Env:PUBLIC\Desktop\Sourcetree.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Write-Header "Install Visual Studio Code"
#----------------------------------------------------------------------------------------------------

# Visual Studio Code
choco install -y "vscode" --package-parameters="/NoDesktopIcon"
choco install -y "vscode-settingssync"

#----------------------------------------------------------------------------------------------------
Write-Header "Install Visual Studio 2019"
#----------------------------------------------------------------------------------------------------

# Install Visual Studio 2019 Core
choco install -y "visualstudio2019professional" --package-parameters "--passive"

# Install workloads
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

# Cleanup
Remove-Item "$Env:PUBLIC\Desktop\Unity Hub.lnk" -ErrorAction "Ignore"
if (-Not ($Env:Path -Match "dotnet")) {
    Restart-Computer
}
dotnet --info

# Gather installed VS extensions (after VS is installed)
Write-Host "Get list of Visual Studio extensions that are already installed"
$installedVsExtensions = Get-ChildItem -Path "$vsInstallDir\Extensions" -File -Filter "*.vsixmanifest" -Recurse | `
    Select-String -List -Pattern '<Identity .*Id="(.+?)"' | `
    ForEach-Object { $_.Matches.Groups[1].Value } | `
    Sort-Object

# Install extensions from Microsoft
Install-VsixPackage "Diagnostics.DiagnosticsConcurrencyVisualizer2019"   # Concurrency Visualizer for Visual Studio 2019
Install-VsixPackage "VisualStudioPlatformTeam.ProductivityPowerPack2017" # Productivity Power Tools 2017/2019
Install-VsixPackage "VisualStudioProductTeam.ProjectSystemTools"         # Project System Tools
Install-VsixPackage "azsdktm.SecurityIntelliSense-Preview"               # Security IntelliSense

# Install extensions from Mads Kristensen
Install-VsixPackage "MadsKristensen.ignore"                        # .ignore
Install-VsixPackage "MadsKristensen.BrowserLinkInspector2019"      # Browser Link Inspector 2019
Install-VsixPackage "MadsKristensen.DummyTextGenerator"            # Dummy Text Generator
Install-VsixPackage "MadsKristensen.NPMTaskRunner"                 # NPM Task Runner
Install-VsixPackage "MadsKristensen.OpeninVisualStudioCode"        # Open in Visual Studio Code
Install-VsixPackage "MadsKristensen.TrailingWhitespaceVisualizer"  # Trailing Whitespace Visualizer
Install-VsixPackage "MadsKristensen.TypeScriptDefinitionGenerator" # TypeScript Definition Generator
Install-VsixPackage "MadsKristensen.WebEssentials2019"             # Web Essentials 2019

# Install extensions from other providers
Install-VsixPackage "DevartSoftware.DevartT4EditorforVisualStudio"     # Devart T4 Editor for Visual Studio
Install-VsixPackage "GitHub.GitHubExtensionforVisualStudio"            # GitHub Extension for Visual Studio
Install-VsixPackage "EWoodruff.VisualStudioSpellCheckerVS2017andLater" # Visual Studio Spell Checker (VS2017 and Later)

# Trust development certificates
dotnet dev-certs https --trust

#----------------------------------------------------------------------------------------------------
Write-Header "Install developer utilities"
#----------------------------------------------------------------------------------------------------

# Azure CLI
choco install -y "azure-cli"
RefreshEnv

# Devart Code Compare
# https://docs.devart.com/code-compare/
# https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
if (-not (Test-Path "$Env:ProgramFiles\Devart\Code Compare\CodeCompare.exe")) {
    Write-Host "Install Devart Code Compare"
    $file = "$Env:TEMP\codecompare.exe"
    Invoke-WebRequest -Uri "https://www.devart.com/codecompare/codecompare.exe" -OutFile $file -UseBasicParsing
    Start-Process -Filepath $file -ArgumentList "/SILENT /NORESTART" -Wait
    Remove-Item "$Env:PUBLIC\Desktop\Code Compare.lnk" -ErrorAction "Ignore"
}

# Fiddler
choco install -y "fiddler"
RefreshEnv

# GNU Make
choco install -y "make"

# LINQPad
choco install -y "linqpad"
Remove-Item "$Env:OneDrive\Desktop\LINQPad 6 (x64).lnk" -ErrorAction "Ignore"
RefreshEnv

# Node.js
choco install -y "nodejs"
RefreshEnv

# NuGet CLI
Write-Host "Download NuGet CLI"
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "$Env:ProgramFiles\dotnet\nuget.exe" -UseBasicParsing

# Postman
choco install -y "postman"
Remove-Item "$Env:OneDrive\Desktop\Postman.lnk" -ErrorAction "Ignore"

# PowerShell Core
choco install -y "powershell-core" --package-parameters="/CleanUpPath" --install-arguments="ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"
RefreshEnv

# PuTTY
choco install -y "putty"

# Sysinternals
choco install -y "sysinternals"

# WinGPG
Write-Host "Install WinGPG"
$file = "$Env:TEMP\WinGPG-setup.exe"
Invoke-WebRequest -Uri "https://s3.amazonaws.com/assets.scand.com/WinGPG/WinGPG-1.0.1-setup.exe" -OutFile $file -UseBasicParsing
Start-Process -Filepath $file -ArgumentList "/SILENT /NORESTART" -Wait

# WinSCP
choco install -y "winscp"
Remove-Item "$Env:PUBLIC\Desktop\WinSCP.lnk" -ErrorAction "Ignore"

# Wireshark
choco install -y "wireshark"

#----------------------------------------------------------------------------------------------------
Write-Header "Install JetBrains ReSharper"
#----------------------------------------------------------------------------------------------------

# JetBrains ReSharper Ultimate
choco install -y "resharper"

#----------------------------------------------------------------------------------------------------
Write-Header "Install additional frameworks & SDKs"
#----------------------------------------------------------------------------------------------------

choco install -y "netfx-4.8-devpack"
choco install -y "dotnet-5.0-sdk"

#----------------------------------------------------------------------------------------------------
Write-Header "Install database tools"
#----------------------------------------------------------------------------------------------------

choco install -y "azure-data-studio"
choco install -y "postgresql"
choco install -y "pgadmin4"
choco install -y "servicebusexplorer"
choco install -y "sql-server-2019"
choco install -y "sql-server-management-studio"

#----------------------------------------------------------------------------------------------------
Write-Header "Run clean-up scripts"
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
