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

#----------------------------------------------------------------------------------------------------
# Pre
#----------------------------------------------------------------------------------------------------

Disable-UAC

#----------------------------------------------------------------------------------------------------
# Enable Windows Developer Mode
#----------------------------------------------------------------------------------------------------

Write-Host "Enable Windows Developer Mode"
Push-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\"; & {
    Set-ItemProperty -Path "." -Name "AllowDevelopmentWithoutDevLicense" -Type "DWord" -Value "1"
}; Pop-Location

#----------------------------------------------------------------------------------------------------
# Enable Windows Subsystem for Linux (WSL)
#----------------------------------------------------------------------------------------------------

choco install -y "Microsoft-Hyper-V-All"             -source "windowsFeatures"
choco install -y "Microsoft-Windows-Subsystem-Linux" -source "windowsfeatures"

Invoke-WebRequest -Uri "https://aka.ms/wsl-ubuntu-2004" -OutFile "~/Ubuntu.appx" -UseBasicParsing
Add-AppxPackage -Path "~/Ubuntu.appx"

RefreshEnv
Ubuntu2004 install --root
Ubuntu2004 run apt update
Ubuntu2004 run apt upgrade

#----------------------------------------------------------------------------------------------------
# Install additional browsers
#----------------------------------------------------------------------------------------------------

choco install -y "firefox"

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
# Install developer fonts
#----------------------------------------------------------------------------------------------------

choco install -y "cascadiacodepl"
choco install -y "firacode"

#----------------------------------------------------------------------------------------------------
# Install source control tools
#----------------------------------------------------------------------------------------------------

choco install -y "git" --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
choco install -y "github-desktop"
choco install -y "tortoisegit"

#----------------------------------------------------------------------------------------------------
# Install Docker
#----------------------------------------------------------------------------------------------------

Enable-WindowsOptionalFeature -Online -FeatureName "containers" -All

RefreshEnv
choco install -y "docker-for-windows"

#----------------------------------------------------------------------------------------------------
# Install IDEs
#----------------------------------------------------------------------------------------------------

# Visual Studio 2019
choco install -y "visualstudio2019professional"
RefreshEnv
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/VisualStudio.vssettings" -OutFile ".\VisualStudio.vssettings"
devenv /ResetSettings ".\VisualStudio.vssettings"

# JetBrains ReSharper Ultimate
choco install -y "resharper"

# Visual Studio Code
choco install -y "vscode"

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
