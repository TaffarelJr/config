# Load supporting script files
. ".\UserPrompts.ps1"
. ".\Utilities.ps1"

Write-Host "Running all scripts for new machine setup ..."

# Ensure Admin permissions
Test-IsRunningAsAdmin

$isDevMachine = Show-BooleanChoice -Caption "Developer Mode" ` -Message "Will this computer be used for software development?" `
	-YesHelpText "The computer will be configured with more advanced options used for software development." `
	-NoHelpText "The computer will be configured with standard options for regular use."

Push-Location -Path ".\Configure\"
	# Set computer name
	& ".\ComputerName.ps1"

	# Configure Windows Registry settings
	if ($isDevMachine) {
		& ".\DeveloperMode.ps1"
	}
Pop-Location

& ".\UnlockOneDrive.ps1"
& ".\UnlockWindowsStore.ps1"
& ".\ConfigureWindowsExplorer.ps1"
& ".\ConfigureSearchOptions.ps1"
& ".\ConfigureWindowsTheme.ps1"
& ".\OpenCommandWindowHere.ps1"
