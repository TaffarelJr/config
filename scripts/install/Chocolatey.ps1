# Load supporting script files
try {
	. "..\Utilities.ps1"
}
catch { }

# Ensure Admin permissions
Test-IsRunningAsAdmin

function Install-Chocolatey {
	if (test-path "C:\ProgramData\chocolatey\choco.exe") {
		Write-Host "Chocolatey detected"
	}
	else {
		Write-Output "Installing Chocolatey ..."
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
}

Write-Header "Install Chocolatey"

Install-Chocolatey
