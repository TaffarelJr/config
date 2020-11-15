# Load supporting script files
. ".\Utilities.ps1"

Write-Header "Set computer name"

# Ensure Admin permissions
Test-IsRunningAsAdmin

$computerName = Read-Host -Prompt (Add-Indent "What would you like to name this computer?")
Rename-Computer -NewName $computerName
Write-Host "Computer name set to '$($computerName)'"
