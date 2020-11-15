# Load supporting script files
. ".\Utilities.ps1"

Write-Header "Unlock Windows Store"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Host "Unlocking Windows Store ..."
Push-Location -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore\"

Set-ItemProperty -Path "." -Name "DisableStoreApps" -Type "DWord" -Value "0"
Set-ItemProperty -Path "." -Name "RemoveWindowsStore" -Type "DWord" -Value "0"
Set-ItemProperty -Path "." -Name "RequirePrivateStoreOnly" -Type "DWord" -Value "0"

Pop-Location
Write-Host "Done"
