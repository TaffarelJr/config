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

# GIMP
choco install -y $chocoCache "gimp"

# Hugin
choco install -y $chocoCache "hugin"

# Microsoft ICE (retired?)
choco install -y $chocoCache "image-composite-editor"

# Inkscape
choco install -y $chocoCache "inkscape"
Remove-Item "$Env:OneDrive\Desktop\Inkscape.lnk" -ErrorAction "Ignore"

# Shotcut
choco install -y $chocoCache "shotcut"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
