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
Write-Host "Install Devart Code Compare"
Invoke-WebRequest -Uri "https://www.devart.com/codecompare/codecompare.exe" -OutFile "$Env:TEMP\codecompare.exe" -UseBasicParsing
Invoke-Expression "$Env:TEMP\codecompare.exe /SILENT /NORESTART"
Start-Sleep -Seconds 15
Remove-Item "$Env:PUBLIC\Desktop\Code Compare.lnk" -ErrorAction "Ignore"

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

# Visual Studio 2019
choco install -y "visualstudio2019professional"

RefreshEnv
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/VisualStudio.vssettings" -OutFile "$Env:TEMP\VisualStudio.vssettings" -UseBasicParsing
devenv /ResetSettings "$Env:TEMP\VisualStudio.vssettings"

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
