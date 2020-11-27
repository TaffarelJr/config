# Load supporting script files
. "..\Utilities.ps1"

Write-Header "Install Chocolatey"

# Ensure Admin permissions
Test-IsRunningAsAdmin

function Verify-Chocolatey {
	if(test-path "C:\ProgramData\chocolatey\choco.exe"){
		Write-Host "Chocolatey detected"
	} else {
		Write-Output "Installing Chocolatey ..."
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
}

Verify-Chocolatey
