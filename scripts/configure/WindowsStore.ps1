# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Header "Unlock Windows Store"

Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\"
	Write-Host "Enable Store apps"
	Set-ItemProperty -Path "." -Name "DisableStoreApps" -Type "DWord" -Value "0"

	Write-Host "Do not remove Windows Store"
	Set-ItemProperty -Path "." -Name "RemoveWindowsStore" -Type "DWord" -Value "0"

	Write-Host "Do not require private Store only"
	Set-ItemProperty -Path "." -Name "RequirePrivateStoreOnly" -Type "DWord" -Value "0"
Pop-Location
