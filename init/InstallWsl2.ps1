# Requirements:
#     - Windows must be either:
#         - Windows 10 May 2020 (2004)
#         - Windows 10 November 2019 (1909) (w/ https://support.microsoft.com/en-us/help/4566116/windows-10-update-kb4566116)
#         - Windows 10 May 2019 (1903) (w/ https://support.microsoft.com/en-us/help/4566116/windows-10-update-kb4566116)
#     - Computer must have Hyper-V Virtualization support (https://www.zdnet.com/article/windows-10-tip-find-out-if-your-pc-can-run-hyper-v/)

# Load supporting script files
. ".\Utilities.ps1"

Write-Host "Installing Windows Subsystem for Linux (WSL2) ..."

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Make sure the Windows version is appropriate
$windowsRelease = Get-WindowsRelease
if ($windowsRelease -lt 1900) {
	Write-Error "The current system is on Windows release $windowsRelease. Windows Sybsystem for Linux can only be installed on 1903 and later."
}
elseif (windowsRelease -lt 2000) {
	$windowsReleaseIs1900 = $true
}
else {
	$windowsReleaseIs1900 = $false
}

# 1. Enable WSL 2
# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 2. Enable ‘Virtual Machine Platform’
# if ($windowsReleaseIs1900) {
# 	Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
# } else {
# 	dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# }

#
# Must restart here!
#

# 3. Set WSL 2 as default
# wsl --set-default-version 2

# 4. Install a Linux distro
# Windows Store - Ubuntu 20.04 LTS: https://www.microsoft.com/en-gb/p/ubuntu-2004-lts/9n6svws3rx71
# ALSO: Windows Store - Windows Terminal: https://www.microsoft.com/en-gb/p/windows-terminal/9n0dx20hk701

# 5. Use WSL 2
# When you installed Ubuntu (or a different Linux distro) a shortcut was added to the Start Menu.
# Use this to “open” Ubuntu (or whichever distro you chose).
# The first time you run the distro things will seem a little slow.
# This is expected; the distro has to unpack and decompress all of its contents — just don’t interrupt the process.
