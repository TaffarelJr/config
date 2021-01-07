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
# Windows Subsystem for Linux 2 (WSL2)
#----------------------------------------------------------------------------------------------------

$edition = (Get-WindowsEdition -Online).Edition
if ($edition -ne "Home") {
    # WSL 2
    choco install -y "wsl2" --package-parameters="/Retry:true"

    # Ubuntu
    # https://docs.microsoft.com/en-us/windows/wsl/install-manual
    choco install -y "wsl-ubuntu-2004"

    # TODO: Need to somehow launch Ubuntu here, to let it initialize itself

    Write-Host "Setup Ubuntu"
    wsl sudo sh -c '$(curl -fsSL https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Ubuntu.sh)'

    Write-Host "Reboot WSL"
    Restart-Service -Name "LxssManager"
}

#----------------------------------------------------------------------------------------------------
# Docker
#----------------------------------------------------------------------------------------------------

choco install -y "docker-desktop"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
