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
# Install browsers
#----------------------------------------------------------------------------------------------------

# Google Chrome
choco install -y "googlechrome"
Remove-Item "$Env:PUBLIC\Desktop\Google Chrome.lnk"   -ErrorAction "Ignore"
Remove-Item "$Env:OneDrive\Desktop\Google Chrome.lnk" -ErrorAction "Ignore"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/Chrome.json" -OutFile "$Env:ProgramFiles\Google\Chrome\Application\master_preferences" -UseBasicParsing

#----------------------------------------------------------------------------------------------------
# Install utilities
#----------------------------------------------------------------------------------------------------

# 7-Zip
choco install -y "7zip"

# Piriform CCleaner
choco install -y "ccleaner"
Remove-Item "$Env:PUBLIC\Desktop\CCleaner.lnk" -ErrorAction "Ignore"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TaffarelJr/config/main/apps/CCleaner.ini" -OutFile "$Env:ProgramFiles\CCleaner\ccleaner.ini" -UseBasicParsing

# Chocolatey
choco install -y "chocolatey"

# Piriform Defraggler
choco install -y "defraggler"
Remove-Item "$Env:PUBLIC\Desktop\Defraggler.lnk" -ErrorAction "Ignore"

# Notepad++
choco install -y "notepadplusplus"

# SpaceSniffer
choco install -y "spacesniffer"

#----------------------------------------------------------------------------------------------------
# Install additional cloud storage providers
#----------------------------------------------------------------------------------------------------

# Dropbox
choco install -y "dropbox"

# Google Backup and Sync
choco install -y "google-backup-and-sync"
Remove-Item "$Env:PUBLIC\Desktop\Google Docs.lnk"   -ErrorAction "Ignore"
Remove-Item "$Env:PUBLIC\Desktop\Google Sheets.lnk" -ErrorAction "Ignore"
Remove-Item "$Env:PUBLIC\Desktop\Google Slides.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
# Install communications tools
#----------------------------------------------------------------------------------------------------

# Slack
choco install -y "slack"

# Zoom
choco install -y "zoom" --install-arguments="ZNoDesktopShortCut=true ZRecommend=""DisableVideo=1;MuteVoipWhenJoin=1;AutoJoinVOIP=1"""

#----------------------------------------------------------------------------------------------------
# Install basic graphics tools
#----------------------------------------------------------------------------------------------------

# Paint.net
choco install -y "paint.net"
Remove-Item "$Env:PUBLIC\Desktop\paint.net.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
# Post
#----------------------------------------------------------------------------------------------------

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
