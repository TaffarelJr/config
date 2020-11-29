# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Install Piriform CCleaner"

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Install Chocolatey if necessary
if (-NOT (Get-Command 'Verify-Chocolatey' -errorAction SilentlyContinue)) {
	. ".\Chocolatey.ps1"
}

choco install ccleaner -y
