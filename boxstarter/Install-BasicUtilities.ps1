# Boxstarter Script to apply standard configuration and install common applications.
# https://boxstarter.org/
#
# Install Boxstarter:
# 	. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# Set: Set-ExecutionPolicy RemoteSigned
# Then: Install-BoxstarterPackage -PackageName <URL-TO-RAW-OR-GIST> -DisableReboots
#
# Pulled from samples by:
# - Microsoft https://github.com/Microsoft/windows-dev-box-setup-scripts
# - elithrar https://github.com/elithrar/dotfiles
# - ElJefeDSecurIT https://gist.github.com/ElJefeDSecurIT/014fcfb87a7372d64934995b5f09683e
# - jessfraz https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# - NickCraver https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

#----------------------------------------------------------------------------------------------------
# Pre
#----------------------------------------------------------------------------------------------------

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
