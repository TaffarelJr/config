# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Header "Set computer name"

Write-Host "Computer name is: $env:computername"
Write-Host "Would you like to rename it?"
$computerName = Read-Host -Prompt (Add-Indent "<press ENTER to skip>")

Write-Host
if ($computerName.Length -gt 0) {
	Write-Host "Renaming ..."
	Rename-Computer -NewName $computerName
	Write-Host "Done. A restart will be required before this takes effect."
} else {
	Write-Host "Skipping ..."
}
