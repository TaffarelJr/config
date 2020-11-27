# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Set computer name"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Host "Computer name is: $env:computername"
Write-Host "Would you like to rename it?"
$computerName = Read-Host -Prompt (Add-Indent "<press ENTER to skip>")

if ($computerName.Length -gt 0) {
	Write-Host "Renaming computer ..."
	Rename-Computer -NewName $computerName
	Write-Host "Done"
}
