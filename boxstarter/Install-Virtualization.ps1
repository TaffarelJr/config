#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Validate Windows version
if ($edition -EQ "Home") {
    throw [System.IO.InvalidOperationException] "This script cannot be run on Windows 10 Home Edition"
}

# Download & import utilities
$repoUri = "https://raw.githubusercontent.com/TaffarelJr/config/main"
$utilitiesFilename = "Utilities.ps1"
$utilitiesUri = "$repoUri/boxstarter/$utilitiesFilename"
$utilitiesLocalPath = "$Env:TEMP\$utilitiesFilename"
Write-Host "Download & import $utilitiesUri"
Invoke-WebRequest -Uri $utilitiesUri -OutFile $utilitiesLocalPath -UseBasicParsing
. $utilitiesLocalPath

#----------------------------------------------------------------------------------------------------
Write-Header "Install Microsoft Hyper-V"
#----------------------------------------------------------------------------------------------------

# Let Boxstarter/Chocolatey install Hyper-V instead of Windows, so it can manage reboots
choco install -y $chocoCache "Microsoft-Hyper-V-All" -source "windowsfeatures"

# Manually trigger a reboot here, to avoid error text when installing WSL2 (next)
if ($LastExitCode -EQ 3010) { Invoke-Reboot }

#----------------------------------------------------------------------------------------------------
Write-Header "Install Windows Subsystem for Linux 2 (WSL2)"
#----------------------------------------------------------------------------------------------------

# Install WSL 2
choco install -y $chocoCache "wsl2"

# Install Ubuntu
# https://docs.microsoft.com/en-us/windows/wsl/install-manual
choco install -y $chocoCache "wsl-ubuntu-2004"

# Display instructions
Write-Host "Initialize Ubuntu"
Write-Host "This will launch the Ubuntu shell in a separate window."
Write-Host "You will be prompted to create a user account."
Write-Host "You will then need to execute these two command lines:"
Write-Host "    sudo sh -c `"`$(curl -fsSL $repoUri/boxstarter/Ubuntu.sh)`""
Write-Host "    sh -c `"`$(curl -fsSL $repoUri/boxstarter/Homebrew.sh)`""

# Launch Ubuntu and allow it to initialize
$ubuntu = Get-ChildItem "$Env:ProgramFiles\WindowsApps\" | `
    ForEach-Object { Get-ItemProperty $_.PSPath } | `
    Where-Object { $_ -Match "Ubuntu" } | `
    Get-ChildItem | `
    ForEach-Object { Get-ItemProperty $_.PSPath } | `
    Where-Object { $_ -Match ".exe" }
Start-Process $ubuntu -Wait

# Reboot WSL to make sure changes take effect
Write-Host "Reboot WSL"
Restart-Service -Name "LxssManager"

#----------------------------------------------------------------------------------------------------
Write-Header "Install Docker"
#----------------------------------------------------------------------------------------------------

choco install -y $chocoCache "docker-desktop"
Remove-Item "$Env:OneDrive\Desktop\Docker Desktop.lnk" -ErrorAction "Ignore"
RefreshEnv

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
