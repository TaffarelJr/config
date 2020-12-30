# Load supporting script files
. "..\..\..\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Install Chocolatey if necessary
if (-NOT (Get-Command 'Install-Chocolatey' -errorAction SilentlyContinue)) {
    . ".\Chocolatey.ps1"
}

Write-Header "Install .NET Framework 4.8 SDK"
choco install netfx-4.8-devpack -y
