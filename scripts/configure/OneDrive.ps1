# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Header "Unlock Microsoft OneDrive"

Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive\"
	Write-Host "Enable file sync"
	Set-ItemProperty -Path "." -Name "DisableFileSync" -Type "DWord" -Value "0"

	Write-Host "Enable file sync (next-gen)"
	Set-ItemProperty -Path "." -Name "DisableFileSyncNGSC" -Type "DWord" -Value "0"
Pop-Location
