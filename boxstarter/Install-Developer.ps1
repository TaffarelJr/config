#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$repoUri = "https://raw.githubusercontent.com/TaffarelJr/config/main"
$fileUri = "$repoUri/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $fileUri"
Invoke-WebRequest -Uri $fileUri -OutFile $filePath -UseBasicParsing
. $filePath

#----------------------------------------------------------------------------------------------------
Write-Header "Enable Windows Developer Mode"
#----------------------------------------------------------------------------------------------------

Enter-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\" {
    Set-ItemProperty -Path "." -Name "AllowDevelopmentWithoutDevLicense" -Type "DWord" -Value 1
}

#----------------------------------------------------------------------------------------------------
Write-Header "Install additional browsers"
#----------------------------------------------------------------------------------------------------

# Firefox
choco install -y $chocoCache "firefox" --package-parameters="/NoDesktopShortcut /RemoveDistributionDir"

#----------------------------------------------------------------------------------------------------
Write-Header "Install source control tools"
#----------------------------------------------------------------------------------------------------

# Git for Windows
choco install -y $chocoCache "git"
RefreshEnv

# TortoiseGit
choco install -y $chocoCache "tortoisegit"
RefreshEnv

# GitHub Desktop
choco install -y $chocoCache "github-desktop" --install-arguments="-s"
Remove-Item "$Env:OneDrive\Desktop\GitHub Desktop.lnk" -ErrorAction "Ignore"
RefreshEnv

# Sourcetree
choco install -y $chocoCache "sourcetree"
Remove-Item "$Env:PUBLIC\Desktop\Sourcetree.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Write-Header "Install Visual Studio Code"
#----------------------------------------------------------------------------------------------------

# Visual Studio Code
choco install -y $chocoCache "vscode" --package-parameters="/NoDesktopIcon"
choco install -y $chocoCache "vscode-settingssync"
RefreshEnv

#----------------------------------------------------------------------------------------------------
Write-Header "Install Visual Studio 2019"
#----------------------------------------------------------------------------------------------------

# Install Visual Studio 2019 Core
choco install -y $chocoCache "visualstudio2019professional" --package-parameters "--passive"

# Install workloads
choco install -y $chocoCache "visualstudio2019-workload-azure"                 --package-parameters "--passive --includeOptional" # Azure development workload
choco install -y $chocoCache "visualstudio2019-workload-data"                  --package-parameters "--passive --includeOptional" # Data storage and processing workload
# choco install -y $chocoCache "visualstudio2019-workload-datascience"           --package-parameters "--passive --includeOptional" # Data science and analytical applications workload
choco install -y $chocoCache "visualstudio2019-workload-manageddesktop"        --package-parameters "--passive --includeOptional" # .NET desktop develoment workload
choco install -y $chocoCache "visualstudio2019-workload-managedgame"           --package-parameters "--passive --includeOptional" # Game development with Unity workload
# choco install -y $chocoCache "visualstudio2019-workload-nativecrossplat"       --package-parameters "--passive --includeOptional" # Linux development with C++ workload
# choco install -y $chocoCache "visualstudio2019-workload-nativedesktop"         --package-parameters "--passive --includeOptional" # Desktop development with C++ workload
# choco install -y $chocoCache "visualstudio2019-workload-nativegame"            --package-parameters "--passive --includeOptional" # Game development with C++ workload
# choco install -y $chocoCache "visualstudio2019-workload-nativemobile"          --package-parameters "--passive --includeOptional" # Mobile development with C++ workload
choco install -y $chocoCache "visualstudio2019-workload-netcoretools"          --package-parameters "--passive --includeOptional" # .NET Core cross-platform development workload
# choco install -y $chocoCache "visualstudio2019-workload-netcrossplat"          --package-parameters "--passive --includeOptional" # Mobile development with .NET workload
choco install -y $chocoCache "visualstudio2019-workload-netweb"                --package-parameters "--passive --includeOptional" # ASP.NET and web development workload
# choco install -y $chocoCache "visualstudio2019-workload-node"                  --package-parameters "--passive --includeOptional" # Node.js development workload
# choco install -y $chocoCache "visualstudio2019-workload-office"                --package-parameters "--passive --includeOptional" # Office/SharePoint development workload
# choco install -y $chocoCache "visualstudio2019-workload-python"                --package-parameters "--passive --includeOptional" # Python development workload
choco install -y $chocoCache "visualstudio2019-workload-universal"             --package-parameters "--passive --includeOptional" # Universal Windows Platform development workload
# choco install -y $chocoCache "visualstudio2019-workload-visualstudioextension" --package-parameters "--passive --includeOptional" # Visual Studio extension development workload

# Cleanup & reboot
Remove-Item "$Env:PUBLIC\Desktop\Unity Hub.lnk" -ErrorAction "Ignore"
if (-Not ($Env:Path -Match "dotnet")) { Invoke-Reboot }
dotnet --info

# Trust development certificates
dotnet dev-certs https --trust

#----------------------------------------------------------------------------------------------------
Write-Header "Install Visual Studio 2019 Extensions"
#----------------------------------------------------------------------------------------------------

# Determine which VSIX are already installed
$installed = Get-InstalledVsix

# Start a session on the Visual Studio Marketplace
Write-Host "Start a new session with Visual Studio Marketplace"
$response = Invoke-WebRequest -Uri $vsMarketplace -UseBasicParsing -UseDefaultCredentials -SessionVariable "session"
if ($response.StatusCode -NE 200) { throw [System.IO.InvalidOperationException] "Could not establish a session with Visual Studio Marketplace at $vsMarketplace" }

# Determine which VSIX are to be installed, download them, and install them
@(
    # Install extensions from Microsoft
    "Diagnostics.DiagnosticsConcurrencyVisualizer2019"   # Concurrency Visualizer for Visual Studio 2019
    "VisualStudioPlatformTeam.ProductivityPowerPack2017" # Productivity Power Tools 2017/2019
    "VisualStudioProductTeam.ProjectSystemTools"         # Project System Tools
    "azsdktm.SecurityIntelliSense-Preview"               # Security IntelliSense
    # Install extensions from Mads Kristensen
    "MadsKristensen.ignore"                              # .ignore
    "MadsKristensen.BrowserLinkInspector2019"            # Browser Link Inspector 2019
    "MadsKristensen.DummyTextGenerator"                  # Dummy Text Generator
    "MadsKristensen.NPMTaskRunner"                       # NPM Task Runner
    "MadsKristensen.OpeninVisualStudioCode"              # Open in Visual Studio Code
    "MadsKristensen.TrailingWhitespaceVisualizer"        # Trailing Whitespace Visualizer
    "MadsKristensen.TypeScriptDefinitionGenerator"       # TypeScript Definition Generator
    "MadsKristensen.WebEssentials2019"                   # Web Essentials 2019
    # Install extensions from other providers
    "DevartSoftware.DevartT4EditorforVisualStudio"       # Devart T4 Editor for Visual Studio
    "GitHub.GitHubExtensionforVisualStudio"              # GitHub Extension for Visual Studio
    "EWoodruff.VisualStudioSpellCheckerVS2017andLater"   # Visual Studio Spell Checker (VS2017 and Later)
) | Get-VsixInfo -Session $session | Where-Object { $installed -NotContains $_.Id } | Get-Vsix -Session $session | Install-Vsix

#----------------------------------------------------------------------------------------------------
Write-Header "Install developer utilities"
#----------------------------------------------------------------------------------------------------

# Azure CLI
choco install -y $chocoCache "azure-cli"
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
choco install -y $chocoCache "fiddler"
RefreshEnv

# GNU Make
choco install -y $chocoCache "make"

# LINQPad
choco install -y $chocoCache "linqpad"
Remove-Item "$Env:OneDrive\Desktop\LINQPad 6 (x64).lnk" -ErrorAction "Ignore"
RefreshEnv

# Node.js
choco install -y $chocoCache "nodejs"
RefreshEnv

# NuGet CLI
Write-Host "Download NuGet CLI"
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "$Env:ProgramFiles\dotnet\nuget.exe" -UseBasicParsing

# Postman
choco install -y $chocoCache "postman"
Remove-Item "$Env:OneDrive\Desktop\Postman.lnk" -ErrorAction "Ignore"

# PuTTY
choco install -y $chocoCache "putty"

# Sysinternals
choco install -y $chocoCache "sysinternals"

# WinGPG
Write-Host "Install WinGPG"
$file = "$Env:TEMP\WinGPG-setup.exe"
Invoke-WebRequest -Uri "https://s3.amazonaws.com/assets.scand.com/WinGPG/WinGPG-1.0.1-setup.exe" -OutFile $file -UseBasicParsing
Start-Process -Filepath $file -ArgumentList "/SILENT /NORESTART" -Wait

# WinSCP
choco install -y $chocoCache "winscp"
Remove-Item "$Env:PUBLIC\Desktop\WinSCP.lnk" -ErrorAction "Ignore"

# Wireshark
choco install -y $chocoCache "wireshark"

#----------------------------------------------------------------------------------------------------
Write-Header "Install JetBrains ReSharper"
#----------------------------------------------------------------------------------------------------

# JetBrains ReSharper Ultimate
choco install -y $chocoCache "resharper-ultimate-all" --package-parameters "/NoCpp"

#----------------------------------------------------------------------------------------------------
Write-Header "Install SQL Server Developer Edition"
#----------------------------------------------------------------------------------------------------

# SQL Server
choco install -y $chocoCache "sql-server-2019"
RefreshEnv

# SQL Server Management Studio
choco install -y $chocoCache "sql-server-management-studio"
RefreshEnv

#----------------------------------------------------------------------------------------------------
Write-Header "Install Azure data tools"
#----------------------------------------------------------------------------------------------------

# Azure Data Studio
choco install -y $chocoCache "azure-data-studio"

# Azure Service Bus Explorer
choco install -y $chocoCache "servicebusexplorer"

#----------------------------------------------------------------------------------------------------
Write-Header "Install PostgreSQL"
#----------------------------------------------------------------------------------------------------

# Prompt the user for a password
$password = ""
while ($password.Length -eq 0) {
    $password = Read-Host -Prompt "Enter a password for PostgreSQL"
}

# PostgreSQL
choco install -y $chocoCache "postgresql" --package-parameters "/Password:$password"
RefreshEnv

# pgAdmin4
choco install -y $chocoCache "pgadmin4"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
