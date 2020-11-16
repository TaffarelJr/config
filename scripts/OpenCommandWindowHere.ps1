# Load supporting script files
. ".\Utilities.ps1"

function Set-RegistryEntries {
	# Normal
	New-Item -Path "." -Name "cmd" -Value "@shell32.dll,-8506" -Force | out-null
	Set-ItemProperty -Path ".\cmd\" -Name "NoWorkingDirectory" -Value ""
	New-Item -Path ".\cmd\" -Name "command" -Value "cmd.exe /s /k pushd ""%V""" -Force | out-null

	# As Administrator
	New-Item -Path "." -Name "runas" -Value "Open command window here as Administrator" -Force | out-null
	Set-ItemProperty -Path ".\runas\" -Name "HasLUAShield" -Value ""
	Set-ItemProperty -Path ".\runas\" -Name "Extended" -Value ""
	New-Item -Path ".\runas\" -Name "command" -Value "cmd.exe /s /k pushd ""%V""" -Force | out-null
}

Write-Header "Open Command Window Here"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Host "Adding 'Open Command Window Here' prompts to context menu ..."
New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | out-null
Push-Location -Path "HKCR:\"

Push-Location -Path ".\Directory\shell\"
Set-RegistryEntries
Pop-Location

Push-Location -Path ".\Directory\Background\shell\"
Set-RegistryEntries
Pop-Location

Push-Location -Path ".\Drive\shell\"
Set-RegistryEntries
Pop-Location

Pop-Location
Write-Host "Done"
