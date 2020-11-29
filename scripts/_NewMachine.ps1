# Load supporting script files
. ".\UserPrompts.ps1"
. ".\Utilities.ps1"

# Ensure Admin permissions
Test-IsRunningAsAdmin

Write-Host "Running all scripts for new machine setup ..."

# Prompt for user input
$isRJsProfile = Show-BooleanChoice -Caption "RJ's Profile" -Message "Is this RJ's user profile?" `
	-YesHelpText "The current user profile will be configured the way RJ likes it." `
	-NoHelpText "The current user profile will not be configured."
if ($isRJsProfile) {
	$isDevMachine = Show-BooleanChoice -Caption "Developer Mode" -Message "Will this computer be used for software development?" `
		-YesHelpText "The computer will be configured with more advanced options used for software development." `
		-NoHelpText "The computer will be configured with standard options for regular use."
}

$installAdvGraphicsTools = Show-BooleanChoice -Caption "Graphics Tools" -Message "Install advanced graphics editing tools?" `
	-YesHelpText "Install advanced graphics editing tools." `
	-NoHelpText "Do not install advanced graphics editing tools."

Push-Location -Path ".\configure\"
	# Set computer name
	& ".\ComputerName.ps1"

	# Configure Windows
	& ".\OneDrive.ps1"
	& ".\OpenCommandWindowHere.ps1"
	& ".\SearchExtensions.ps1"
	& ".\WindowsExplorer.ps1"
	& ".\WindowsStore.ps1"
	if ($isRJsProfile) {
		& ".\SearchOptions.ps1"
		& ".\WindowsTheme.ps1"
		if ($isDevMachine) {
			& ".\DeveloperMode.ps1"
		}
	}
Pop-Location

Push-Location -Path ".\install\"
	# Install Chocolatey
	. ".\Chocolatey.ps1"

	# Install Browsers
	& ".\GoogleChrome.ps1"

	# Install utilities
	& ".\7Zip.ps1"
	& ".\AttributeChanger.ps1"
	& ".\LinkShellExtension.ps1"
	& ".\NotepadPlusPlus.ps1"
	& ".\PiriformCCleaner.ps1"
	& ".\PiriformDefraggler.ps1"
	& ".\SpaceSniffer.ps1"
	if ($isRJsProfile) {
		& ".\AdvancedRenamer.ps1"
		& ".\Divvy.ps1"
		& ".\DuplicateCleaner.ps1"
		& ".\FreeDownloadManager.ps1"
	}

	# Install cloud storage
	& ".\Dropbox.ps1"
	& ".\GoogleBackupAndSync.ps1"

	# Install communications tools
	& ".\Slack.ps1"
	& ".\Zoom.ps1"

	# Install graphics tools
	& ".\Paint.NET.ps1"
	if ($installAdvGraphicsTools) {
		& ".\Gimp.ps1"
		& ".\Hugin.ps1"
		& ".\Inkscape.ps1"
		& ".\MicrosoftICE.ps1"
	}
Pop-Location
