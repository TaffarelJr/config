# Load supporting script files
. "..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Install Chocolatey if necessary
if (-NOT (Get-Command 'Verify-Chocolatey' -errorAction SilentlyContinue)) {
	. ".\Chocolatey.ps1"
}

Write-Header "Install Space Sniffer"

choco install spacesniffer -y
