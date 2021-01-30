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
Write-Header "Install browsers"
#----------------------------------------------------------------------------------------------------

# Google Chrome
choco install -y $chocoCache "googlechrome"
Remove-Item "$Env:PUBLIC\Desktop\Google Chrome.lnk"   -ErrorAction "Ignore"
Remove-Item "$Env:OneDrive\Desktop\Google Chrome.lnk" -ErrorAction "Ignore"
Invoke-WebRequest -Uri "$repoUri/apps/Chrome.json" -OutFile "$Env:ProgramFiles\Google\Chrome\Application\master_preferences" -UseBasicParsing

#----------------------------------------------------------------------------------------------------
Write-Header "Install utilities"
#----------------------------------------------------------------------------------------------------

# 7-Zip
choco install -y $chocoCache "7zip"

# Piriform CCleaner
choco install -y $chocoCache "ccleaner"
Remove-Item "$Env:PUBLIC\Desktop\CCleaner.lnk" -ErrorAction "Ignore"
Invoke-WebRequest -Uri "$repoUri/apps/CCleaner.ini" -OutFile "$Env:ProgramFiles\CCleaner\ccleaner.ini" -UseBasicParsing

# Chocolatey
choco install -y $chocoCache "chocolatey"

# Piriform Defraggler
choco install -y $chocoCache "defraggler"
Remove-Item "$Env:PUBLIC\Desktop\Defraggler.lnk" -ErrorAction "Ignore"

# Notepad++
choco install -y $chocoCache "notepadplusplus"

# PowerShell Core
choco install -y $chocoCache "powershell-core" --package-parameters="/CleanUpPath" --install-arguments="ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"
RefreshEnv

# SpaceSniffer
choco install -y $chocoCache "spacesniffer"

#----------------------------------------------------------------------------------------------------
Write-Header "Install cloud storage providers"
#----------------------------------------------------------------------------------------------------

# Dropbox
choco install -y $chocoCache "dropbox"

# Google Backup and Sync
choco install -y $chocoCache "google-backup-and-sync" --ignore-checksums # Workaround
Remove-Item "$Env:PUBLIC\Desktop\Google Docs.lnk"   -ErrorAction "Ignore"
Remove-Item "$Env:PUBLIC\Desktop\Google Sheets.lnk" -ErrorAction "Ignore"
Remove-Item "$Env:PUBLIC\Desktop\Google Slides.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Write-Header "Install communications tools"
#----------------------------------------------------------------------------------------------------

# Slack
choco install -y $chocoCache "slack"

# Zoom
choco install -y $chocoCache "zoom" --install-arguments="ZNoDesktopShortCut=true ZRecommend=""DisableVideo=1;MuteVoipWhenJoin=1;AutoJoinVOIP=1"""

#----------------------------------------------------------------------------------------------------
Write-Header "Install basic graphics tools"
#----------------------------------------------------------------------------------------------------

# Paint.net
choco install -y $chocoCache "paint.net"
Remove-Item "$Env:PUBLIC\Desktop\paint.net.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
