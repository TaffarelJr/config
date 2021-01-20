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
# Install advanced graphics tools
#----------------------------------------------------------------------------------------------------

choco install -y "gimp"
choco install -y "hugin"
choco install -y "image-composite-editor"
choco install -y "inkscape"
choco install -y "shotcut"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
