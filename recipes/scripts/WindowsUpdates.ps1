# Load supporting script files
$utilityFile = ".\Utilities.ps1"
if (Test-Path $utilityFile) { . $utilityFile }

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Header "Install Windows Updates"

Install-WindowsUpdate -AcceptEula
