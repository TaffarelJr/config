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
Write-Header "Install game platforms"
#----------------------------------------------------------------------------------------------------

choco install -y $chocoCache "origin"
choco install -y $chocoCache "steam"
choco install -y $chocoCache "uplay"

#----------------------------------------------------------------------------------------------------
Write-Header "Install individual games"
#----------------------------------------------------------------------------------------------------

choco install -y $chocoCache "minecraft-launcher"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
