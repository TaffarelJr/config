# Load supporting script files
. "..\..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Install Chocolatey if necessary
if (-NOT (Get-Command 'Install-Chocolatey' -errorAction SilentlyContinue)) {
    . ".\Chocolatey.ps1"
}

Write-Header "Install Ubisoft Uplay"
choco install uplay -y
