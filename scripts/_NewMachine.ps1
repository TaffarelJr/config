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

$installGames = Show-BooleanChoice -Caption "Games" -Message "Install games?" `
	-YesHelpText "Install games." `
	-NoHelpText "Do not install games."

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
	. ".\Chocolatey.ps1"

	Push-Location -Path ".\browsers\"
		& ".\GoogleChrome.ps1"
		if ($isDevMachine) {
			& ".\Firefox.ps1"
		}
	Pop-Location

	Push-Location -Path ".\utilities\"
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
	Pop-Location

	Push-Location -Path ".\cloudStorage\"
		& ".\Dropbox.ps1"
		& ".\GoogleBackupAndSync.ps1"
	Pop-Location

	Push-Location -Path ".\communications\"
		& ".\Slack.ps1"
		& ".\Zoom.ps1"
	Pop-Location

	if ($isDevMachine) {
		Push-Location -Path ".\development\"
			Push-Location -Path ".\utilities\"
				& ".\Fiddler.ps1"
				& ".\Postman.ps1"
				& ".\PuTTY.ps1"
				& ".\Sysinternals.ps1"
				& ".\WinSCP.ps1"
				& ".\Wireshark.ps1"
			Pop-Location

			Push-Location -Path ".\fonts\"
				& ".\CascadiaCodePL.ps1"
				& ".\FiraCode.ps1"
			Pop-Location

			Push-Location -Path ".\sourceControl\"
				& ".\Git.ps1"
				& ".\GitHubDesktop.ps1"
				& ".\TortoiseGit.ps1"
			Pop-Location

			Push-Location -Path ".\tools\"
				& ".\LINQPad.ps1"
				& ".\Make.ps1"
				& ".\Node.js.ps1"
				& ".\NuGetCLI.ps1"
				& ".\VisualStudio2019.ps1"
				& ".\VisualStudioCode.ps1"
			Pop-Location
		Pop-Location
	}

	Push-Location -Path ".\graphics\"
		& ".\Paint.NET.ps1"
		if ($installAdvGraphicsTools) {
			& ".\Gimp.ps1"
			& ".\Hugin.ps1"
			& ".\Inkscape.ps1"
			& ".\MicrosoftICE.ps1"
			& ".\Shotcut.ps1"
		}
	Pop-Location

	if ($installGames) {
		Push-Location -Path ".\games\"
			& ".\EAOrigin.ps1"
			& ".\Minecraft.ps1"
			& ".\Steam.ps1"
			& ".\UbisoftUplay.ps1"
		Pop-Location
	}
Pop-Location
