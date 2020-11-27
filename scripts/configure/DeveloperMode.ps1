# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Enable Windows developer mode"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Push-Location -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\"
	Write-Host "Allow Windows Store development without a Dev licence"
	Set-ItemProperty -Path "." -Name "AllowDevelopmentWithoutDevLicense" -Type "DWord" -Value "1"
Pop-Location
