# Load supporting script files
. ".\UserPrompts.ps1"
. ".\Utilities.ps1"

Write-Host "Running all scripts for new machine setup ..."

# Ensure Admin permissions
Test-IsRunningAsAdmin

# Prompt for user input
$isRJsProfile = Show-BooleanChoice -Caption "RJ's Profile" -Message "Is this RJ's user profile?" `
	-YesHelpText "The current user profile will be configured the way RJ likes it." `
	-NoHelpText "The current user profile will not be configured."
if ($isRJsProfile) {
	$isDevMachine = Show-BooleanChoice -Caption "Developer Mode" -Message "Will this computer be used for software development?" `
		-YesHelpText "The computer will be configured with more advanced options used for software development." `
		-NoHelpText "The computer will be configured with standard options for regular use."
}

Push-Location -Path ".\configure\"
	# Set computer name
	& ".\ComputerName.ps1"

	# Configure Windows
	& ".\WindowsExplorer.ps1"
	& ".\OpenCommandWindowHere.ps1"
	if ($isRJsProfile) {
		& ".\WindowsTheme.ps1"
		if ($isDevMachine) {
			& ".\DeveloperMode.ps1"
		}
	}

	# Configure Windows Search
	& ".\SearchExtensions.ps1"
	if ($isRJsProfile) {
		& ".\SearchOptions.ps1"
	}

	# Make sure Windows features are unlocked
	& ".\OneDrive.ps1"
	& ".\WindowsStore.ps1"
Pop-Location

Push-Location -Path ".\install\"
	. ".\Chocolatey.ps1"
Pop-Location
