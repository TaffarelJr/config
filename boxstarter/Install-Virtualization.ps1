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
Write-Host "Install Windows Subsystem for Linux 2 (WSL2)"
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
    wsl sudo sh -c '$(curl -fsSL https://raw.githubusercontent.com/TaffarelJr/config/test/boxstarter/Ubuntu.sh)'

    Write-Host "Reboot WSL"
    Restart-Service -Name "LxssManager"
}

#----------------------------------------------------------------------------------------------------
Write-Host "Install Docker"
#----------------------------------------------------------------------------------------------------

choco install -y "docker-desktop"
Remove-Item "$Env:OneDrive\Desktop\Docker Desktop.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
