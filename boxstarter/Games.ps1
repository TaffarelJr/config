#----------------------------------------------------------------------------------------------------
Write-Host "Run startup scripts"
#----------------------------------------------------------------------------------------------------

# Download & import utilities
$repoUri = "https://raw.githubusercontent.com/TaffarelJr/config/test"
$fileUri = "$repoUri/boxstarter/Utilities.ps1"
$filePath = "$Env:TEMP\Utilities.ps1"
Write-Host "Download & import $fileUri"
Invoke-WebRequest -Uri $fileUri -OutFile $filePath -UseBasicParsing
. $filePath

#----------------------------------------------------------------------------------------------------
Write-Header "Install game platforms"
#----------------------------------------------------------------------------------------------------

# EA Origin
choco install -y $chocoCache "origin"

# Steam
choco install -y $chocoCache "steam"
Remove-Item "$Env:PUBLIC\Desktop\Steam.lnk" -ErrorAction "Ignore"
"Steam Client Service" | Disable-WindowsService
Stop-Process -Name "steam" -Force -ErrorAction "Ignore"
"Steam" | Disable-Startup

# Ubisoft Connect
choco install -y $chocoCache "uplay"
Remove-Item "$Env:OneDrive\Desktop\Ubisoft Connect.lnk" -ErrorAction "Ignore"

#----------------------------------------------------------------------------------------------------
Write-Header "Install individual games"
#----------------------------------------------------------------------------------------------------

# Minecraft (Java Edition)
choco install -y $chocoCache "minecraft-launcher" --package-parameters="/NOICON"

#----------------------------------------------------------------------------------------------------
Invoke-CleanupScripts
#----------------------------------------------------------------------------------------------------
