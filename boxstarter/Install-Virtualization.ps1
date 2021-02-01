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
Write-Header "Install Microsoft Hyper-V"
#----------------------------------------------------------------------------------------------------

if ($edition -EQ "Home") {
    Write-Host "<not available on Home edition of Windows>"
}
else {
    choco install -y $chocoCache "Microsoft-Hyper-V-All" -source "windowsfeatures"
}

#----------------------------------------------------------------------------------------------------
Write-Header "Install Windows Subsystem for Linux 2 (WSL2)"
#----------------------------------------------------------------------------------------------------

if ($edition -EQ "Home") {
    Write-Host "<not available on Home edition of Windows>"
}
else {
    # Install WSL 2
    choco install -y $chocoCache "wsl2" --package-parameters="/Retry:true"

    # Install Ubuntu
    # https://docs.microsoft.com/en-us/windows/wsl/install-manual
    choco install -y $chocoCache "wsl-ubuntu-2004"

    # Launch Ubuntu and allow it to initialize
    Write-Host "Initialize Ubuntu"
    $ubuntu = Get-ChildItem "$Env:ProgramFiles\WindowsApps\" | `
        ForEach-Object { Get-ItemProperty $_.PSPath } | `
        Where-Object { $_ -Match "Ubuntu" } | `
        Get-ChildItem | `
        ForEach-Object { Get-ItemProperty $_.PSPath } | `
        Where-Object { $_ -Match ".exe" }
    start-process $ubuntu -Wait

    # Configure Ubuntu
    Write-Host "Run Ubuntu setup script"
    wsl sudo sh -c "`$(curl -fsSL $repoUri/boxstarter/Ubuntu.sh)"

    # Install Homebrew recipies
    Write-Host "Run Homebrew setup script"
    wsl sh -c "`$(curl -fsSL $repoUri/boxstarter/Homebrew.sh)"

    # Reboot WSL to make sure changes take effect
    Write-Host "Reboot WSL"
    Restart-Service -Name "LxssManager"
}

#----------------------------------------------------------------------------------------------------
Write-Header "Install Docker"
#----------------------------------------------------------------------------------------------------

choco install -y $chocoCache "docker-desktop"
Remove-Item "$Env:OneDrive\Desktop\Docker Desktop.lnk" -ErrorAction "Ignore"
RefreshEnv

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
