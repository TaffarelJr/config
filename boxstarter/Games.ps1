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
Write-Header "Install game platforms"
#----------------------------------------------------------------------------------------------------

choco install -y "origin"
choco install -y "steam"
choco install -y "uplay"

#----------------------------------------------------------------------------------------------------
Write-Header "Install individual games"
#----------------------------------------------------------------------------------------------------

choco install -y "minecraft-launcher"

#----------------------------------------------------------------------------------------------------
Write-Header "Run clean-up scripts"
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
