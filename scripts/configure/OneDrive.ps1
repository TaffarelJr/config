# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Unlock Microsoft OneDrive"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Host "Unlocking Microsoft OneDrive ..."
Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive\"
	Set-ItemProperty -Path "." -Name "DisableFileSync" -Type "DWord" -Value "0"
	Set-ItemProperty -Path "." -Name "DisableFileSyncNGSC" -Type "DWord" -Value "0"
Pop-Location
Write-Host "Done"
