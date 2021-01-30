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
Write-Header "Install advanced graphics tools"
#----------------------------------------------------------------------------------------------------

choco install -y $chocoCache "gimp"
choco install -y $chocoCache "hugin"
choco install -y $chocoCache "image-composite-editor"
choco install -y $chocoCache "inkscape"
choco install -y $chocoCache "shotcut"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
