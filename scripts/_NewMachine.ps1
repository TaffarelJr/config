# Load supporting script files
. ".\Utilities.ps1"

Write-Host "Running all scripts for new machine setup ..."

# Ensure Admin permissions
Test-IsRunningAsAdmin

& ".\SetComputerName.ps1"
& ".\EnableDeveloperMode.ps1"
& ".\UnlockOneDrive.ps1"
& ".\UnlockWindowsStore.ps1"
& ".\ConfigureWindowsExplorer.ps1"
& ".\ConfigureSearchOptions.ps1"
& ".\ConfigureWindowsTheme.ps1"
& ".\OpenCommandWindowHere.ps1"
