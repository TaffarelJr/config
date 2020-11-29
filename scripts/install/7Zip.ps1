# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Install 7-Zip"

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Install Chocolatey if necessary
if (-NOT (Get-Command 'Verify-Chocolatey' -errorAction SilentlyContinue)) {
	. ".\Chocolatey.ps1"
}

choco install 7zip -y