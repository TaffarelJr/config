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
# Hyper-V (required for WSL)
#----------------------------------------------------------------------------------------------------

choco install -y "Microsoft-Hyper-V-All" -source "windowsFeatures"

#----------------------------------------------------------------------------------------------------
# Windows Subsystem for Linux 2 (WSL2)
#----------------------------------------------------------------------------------------------------

choco install -y "wsl2" --package-parameters="/Retry:true"
choco install -y "wsl-ubuntu-2004"

# Update Ubuntu with latest packages & install brew
Ubuntu2004 run sudo apt update
Ubuntu2004 run sudo apt upgrade
Ubuntu2004 run sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
Restart-Service -Name "LxssManager"

#----------------------------------------------------------------------------------------------------
# Docker
#----------------------------------------------------------------------------------------------------

Enable-WindowsOptionalFeature -Online -FeatureName "containers" -All
RefreshEnv

choco install -y "docker-for-windows"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula